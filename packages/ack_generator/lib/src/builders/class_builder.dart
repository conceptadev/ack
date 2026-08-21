import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';

import '../models/field_info.dart';
import '../models/model_info.dart';

class _ModelLookups {
  _ModelLookups(List<ModelInfo> models)
    : byClassName = {
        for (final model in models) model.className: model,
      },
      bySchemaName = {
        for (final model in models) model.schemaClassName: model,
      };

  final Map<String, ModelInfo> byClassName;
  final Map<String, ModelInfo> bySchemaName;
}

/// Emits immutable Dart classes from analyzed Ack schemas.
///
/// Ack remains responsible for validation and boundary/runtime codecs. The
/// generated class stores typed fields and delegates parse/encode operations to
/// [AckModelAdapter].
final class AckClassBuilder {
  static const _runtimeMapType = 'Map<String, Object?>';
  static const _jsonMapType = 'Map<String, dynamic>';

  static const _reservedObjectMembers = {
    r'$ack',
    'parse',
    'safeParse',
    'fromMap',
    'fromJson',
    'toMap',
    'toJson',
    'safeToMap',
    'safeToJson',
    '_fromAckRuntime',
    '_toAckRuntime',
    'additionalProperties',
  };

  String? _ackImportPrefix;

  void setAckImportPrefix(String? prefix) {
    _ackImportPrefix = prefix;
  }

  List<Spec> buildClasses(List<ModelInfo> models) {
    if (models.isEmpty) return const [];

    final lookups = _ModelLookups(models);
    _validateModels(models);

    final result = <Spec>[];
    final emittedClassNames = <String>{};

    for (final model in models) {
      if (model.isNullableSchema) {
        throw StateError(
          'Top-level nullable schema "${model.schemaClassName}" cannot '
          'generate a non-nullable model class.',
        );
      }

      if (model.isDiscriminatedBaseDefinition) {
        if (emittedClassNames.add(model.className)) {
          result.add(_buildUnionBase(model, lookups));
        }

        final subtypeNames = model.subtypeNames ?? const <String, String>{};
        for (final entry in subtypeNames.entries) {
          final subtype = lookups.bySchemaName[entry.value];
          if (subtype == null) {
            throw StateError(
              'Could not resolve discriminated branch "${entry.value}" '
              'for ${model.className}.',
            );
          }
          if (emittedClassNames.add(subtype.className)) {
            result.add(
              _buildUnionSubtype(
                subtype,
                baseModel: model,
                discriminatorValue: entry.key,
                lookups: lookups,
              ),
            );
          }
        }
        continue;
      }

      if (model.isDiscriminatedSubtype) continue;
      if (!emittedClassNames.add(model.className)) continue;

      result.add(
        model.representationType == kMapType
            ? _buildObjectClass(model, lookups)
            : _buildValueClass(model),
      );
    }

    return result;
  }

  void _validateModels(List<ModelInfo> models) {
    final classNames = <String>{};
    for (final model in models) {
      if (!classNames.add(model.className)) {
        throw StateError(
          'Multiple @AckType declarations generate the class '
          '"${model.className}".',
        );
      }

      if (model.representationType != kMapType) continue;
      for (final field in model.fields) {
        if (_reservedObjectMembers.contains(field.name)) {
          throw StateError(
            'Schema field "${field.jsonKey}" conflicts with generated member '
            '"${field.name}" on ${model.className}.',
          );
        }
      }
    }
  }

  Class _buildObjectClass(ModelInfo model, _ModelLookups lookups) {
    return Class(
      (b) => b
        ..name = model.className
        ..modifier = ClassModifier.final$
        ..docs.addAll(_buildDocs(model, 'Immutable model'))
        ..fields.addAll([
          for (final field in model.fields) _buildField(field, lookups),
          if (model.additionalProperties) _buildAdditionalPropertiesField(),
          _buildAdapterField(
            model,
            schemaExpression: model.schemaClassName,
          ),
        ])
        ..constructors.addAll([
          _buildObjectConstructor(model, lookups),
          _buildParseFactory(model.className),
          _buildFromMapFactory(model.className),
          _buildFromJsonFactory(model.className),
        ])
        ..methods.addAll([
          _buildSafeParse(model.className),
          _buildToMap(),
          _buildToJson(),
          _buildSafeToMap(),
          _buildSafeToJson(),
          _buildObjectFromRuntime(model, lookups),
          _buildObjectToRuntime(model, lookups),
        ]),
    );
  }

  Class _buildValueClass(ModelInfo model) {
    final className = model.className;
    final runtimeType = model.representationType;

    return Class(
      (b) => b
        ..name = className
        ..modifier = ClassModifier.final$
        ..docs.addAll(_buildDocs(model, 'Immutable value model'))
        ..fields.addAll([
          Field(
            (f) => f
              ..name = 'value'
              ..modifier = FieldModifier.final$
              ..type = refer(runtimeType),
          ),
          _buildAdapterField(
            model,
            schemaExpression: model.schemaClassName,
          ),
        ])
        ..constructors.addAll([
          Constructor(
            (c) => c.requiredParameters.add(
              Parameter(
                (p) => p
                  ..name = 'value'
                  ..toThis = true,
              ),
            ),
          ),
          _buildParseFactory(className),
          Constructor(
            (c) => c
              ..factory = true
              ..name = 'fromJson'
              ..requiredParameters.add(
                Parameter(
                  (p) => p
                    ..name = 'json'
                    ..type = refer('Object?'),
                ),
              )
              ..body = const Code(r'return $ack.parse(json);'),
          ),
        ])
        ..methods.addAll([
          _buildSafeParse(className),
          Method(
            (m) => m
              ..name = 'toJson'
              ..body = const Code(r'return $ack.encode(this);'),
          ),
          Method(
            (m) => m
              ..name = 'safeToJson'
              ..body = const Code(r'return $ack.safeEncode(this);'),
          ),
          Method(
            (m) => m
              ..name = '_fromAckRuntime'
              ..static = true
              ..returns = refer(className)
              ..requiredParameters.add(
                Parameter(
                  (p) => p
                    ..name = 'value'
                    ..type = refer(runtimeType),
                ),
              )
              ..lambda = true
              ..body = Code('$className(value)'),
          ),
          Method(
            (m) => m
              ..name = '_toAckRuntime'
              ..returns = refer(runtimeType)
              ..lambda = true
              ..body = const Code('value'),
          ),
        ]),
    );
  }

  Class _buildUnionBase(ModelInfo model, _ModelLookups lookups) {
    final discriminatorKey = model.discriminatorKey!;
    final cases = <String>[];
    for (final entry in model.subtypeNames!.entries) {
      final subtype = lookups.bySchemaName[entry.value];
      if (subtype == null) continue;
      cases.add(
        '${_stringLiteral(entry.key)} => '
        '${subtype.className}._fromAckRuntime(value)',
      );
    }

    final switchBody = '''
return switch (value[${_stringLiteral(discriminatorKey)}]) {
  ${cases.join(',\n  ')},
  final unknown => throw StateError(
    'Unknown $discriminatorKey: \$unknown',
  ),
};''';

    return Class(
      (b) => b
        ..name = model.className
        ..sealed = true
        ..docs.addAll(_buildDocs(model, 'Discriminated model base'))
        ..fields.add(
          _buildAdapterField(
            model,
            schemaExpression: model.schemaClassName,
          ),
        )
        ..constructors.addAll([
          Constructor((c) => c.constant = true),
          _buildParseFactory(model.className),
          _buildFromMapFactory(model.className),
          _buildFromJsonFactory(model.className),
        ])
        ..methods.addAll([
          _buildSafeParse(model.className),
          Method(
            (m) => m
              ..type = MethodType.getter
              ..name = discriminatorKey
              ..returns = refer('String'),
          ),
          _buildToMap(),
          _buildToJson(),
          _buildSafeToMap(),
          _buildSafeToJson(),
          Method(
            (m) => m
              ..name = '_fromAckRuntime'
              ..static = true
              ..returns = refer(model.className)
              ..requiredParameters.add(
                Parameter(
                  (p) => p
                    ..name = 'value'
                    ..type = refer(_runtimeMapType),
                ),
              )
              ..body = Code(switchBody),
          ),
          Method(
            (m) => m
              ..name = '_toAckRuntime'
              ..returns = refer(_runtimeMapType),
          ),
        ]),
    );
  }

  Class _buildUnionSubtype(
    ModelInfo model, {
    required ModelInfo baseModel,
    required String discriminatorValue,
    required _ModelLookups lookups,
  }) {
    final discriminatorKey = baseModel.discriminatorKey!;
    final effectiveFields = model.fields
        .where((field) => field.jsonKey != discriminatorKey)
        .toList();
    final effectiveModel = ModelInfo(
      className: model.className,
      schemaClassName: model.schemaClassName,
      description: model.description,
      fields: effectiveFields,
      additionalProperties: model.additionalProperties,
      discriminatorKey: discriminatorKey,
      discriminatorValue: discriminatorValue,
      schemaIdentity: model.schemaIdentity,
      discriminatedBaseClassName: baseModel.className,
      representationType: kMapType,
      isNullableSchema: false,
    );

    return Class(
      (b) => b
        ..name = model.className
        ..modifier = ClassModifier.final$
        ..extend = refer(baseModel.className)
        ..docs.addAll(_buildDocs(model, 'Discriminated model branch'))
        ..fields.addAll([
          for (final field in effectiveFields) _buildField(field, lookups),
          if (model.additionalProperties) _buildAdditionalPropertiesField(),
          _buildAdapterField(
            model,
            schemaExpression:
                '${baseModel.schemaClassName}.effectiveBranch('
                '${_stringLiteral(discriminatorValue)})',
          ),
        ])
        ..constructors.addAll([
          _buildObjectConstructor(effectiveModel, lookups),
          _buildParseFactory(model.className),
          _buildFromMapFactory(model.className),
          _buildFromJsonFactory(model.className),
        ])
        ..methods.addAll([
          _buildSafeParse(model.className),
          Method(
            (m) => m
              ..type = MethodType.getter
              ..name = discriminatorKey
              ..returns = refer('String')
              ..lambda = true
              ..body = Code(_stringLiteral(discriminatorValue)),
          ),
          _buildObjectFromRuntime(effectiveModel, lookups),
          _buildObjectToRuntime(
            effectiveModel,
            lookups,
            extraEntries: {
              discriminatorKey: _stringLiteral(discriminatorValue),
            },
          ),
        ]),
    );
  }

  List<String> _buildDocs(ModelInfo model, String kind) {
    return [
      '/// $kind generated from `${model.schemaClassName}`.',
      if (model.description != null) '/// ${model.description}',
    ];
  }

  Field _buildField(FieldInfo field, _ModelLookups lookups) {
    return Field(
      (f) => f
        ..name = field.name
        ..modifier = FieldModifier.final$
        ..type = refer(_fieldType(field, lookups))
        ..docs.addAll([
          if (field.description != null) '/// ${field.description}',
        ]),
    );
  }

  Field _buildAdditionalPropertiesField() {
    return Field(
      (f) => f
        ..name = 'additionalProperties'
        ..modifier = FieldModifier.final$
        ..type = refer(_runtimeMapType)
        ..docs.add(
          '/// Properties accepted by a schema with additional properties.',
        ),
    );
  }

  Field _buildAdapterField(
    ModelInfo model, {
    required String schemaExpression,
  }) {
    final adapter = _qualifyAckSymbol('AckModelAdapter');
    return Field(
      (f) => f
        ..name = r'$ack'
        ..static = true
        ..modifier = FieldModifier.final$
        ..assignment = Code('''
$adapter(
  schema: () => $schemaExpression,
  fromRuntime: ${model.className}._fromAckRuntime,
  toRuntime: (model) => model._toAckRuntime(),
)'''),
    );
  }

  Constructor _buildObjectConstructor(
    ModelInfo model,
    _ModelLookups lookups,
  ) {
    return Constructor(
      (c) {
        for (final field in model.fields) {
          c.optionalParameters.add(
            Parameter(
              (p) => p
                ..name = field.name
                ..named = true
                ..required = field.isRequired
                ..type = refer(_fieldType(field, lookups)),
            ),
          );
          c.initializers.add(
            Code('${field.name} = ${_constructorValue(field)}'),
          );
        }

        if (model.additionalProperties) {
          c.optionalParameters.add(
            Parameter(
              (p) => p
                ..name = 'additionalProperties'
                ..named = true
                ..type = refer(_runtimeMapType)
                ..defaultTo = const Code('const {}'),
            ),
          );
          c.initializers.add(
            const Code(
              'additionalProperties = '
              'Map.unmodifiable(additionalProperties)',
            ),
          );
        }
      },
    );
  }

  String _constructorValue(FieldInfo field) {
    final name = field.name;
    final nullable = field.isNullable || !field.isRequired;

    if (field.isList) {
      return nullable
          ? '$name == null ? null : List.unmodifiable($name)'
          : 'List.unmodifiable($name)';
    }
    if (field.isSet) {
      return nullable
          ? '$name == null ? null : Set.unmodifiable($name)'
          : 'Set.unmodifiable($name)';
    }
    if (field.isMap) {
      return nullable
          ? '$name == null ? null : Map.unmodifiable($name)'
          : 'Map.unmodifiable($name)';
    }
    return name;
  }

  Constructor _buildParseFactory(String className) {
    return Constructor(
      (c) => c
        ..factory = true
        ..name = 'parse'
        ..requiredParameters.add(
          Parameter(
            (p) => p
              ..name = 'input'
              ..type = refer('Object?'),
          ),
        )
        ..body = const Code(r'return $ack.parse(input);'),
    );
  }

  Constructor _buildFromMapFactory(String className) {
    return Constructor(
      (c) => c
        ..factory = true
        ..name = 'fromMap'
        ..requiredParameters.add(
          Parameter(
            (p) => p
              ..name = 'map'
              ..type = refer(_runtimeMapType),
          ),
        )
        ..body = const Code(r'return $ack.parse(map);'),
    );
  }

  Constructor _buildFromJsonFactory(String className) {
    return Constructor(
      (c) => c
        ..factory = true
        ..name = 'fromJson'
        ..requiredParameters.add(
          Parameter(
            (p) => p
              ..name = 'json'
              ..type = refer(_jsonMapType),
          ),
        )
        ..body = const Code(r'return $ack.parse(json);'),
    );
  }

  Method _buildSafeParse(String className) {
    return Method(
      (m) => m
        ..name = 'safeParse'
        ..static = true
        ..returns = refer(
          '${_qualifyAckSymbol('SchemaResult')}<$className>',
        )
        ..requiredParameters.add(
          Parameter(
            (p) => p
              ..name = 'input'
              ..type = refer('Object?'),
          ),
        )
        ..lambda = true
        ..body = const Code(r'$ack.safeParse(input)'),
    );
  }

  Method _buildToMap() {
    return Method(
      (m) => m
        ..name = 'toMap'
        ..returns = refer(_runtimeMapType)
        ..lambda = true
        ..body = const Code(r'$ack.encode(this)'),
    );
  }

  Method _buildToJson() {
    return Method(
      (m) => m
        ..name = 'toJson'
        ..returns = refer(_jsonMapType)
        ..lambda = true
        ..body = const Code('Map<String, dynamic>.from(toMap())'),
    );
  }

  Method _buildSafeToMap() {
    return Method(
      (m) => m
        ..name = 'safeToMap'
        ..returns = refer(
          '${_qualifyAckSymbol('SchemaResult')}<$_runtimeMapType>',
        )
        ..lambda = true
        ..body = const Code(r'$ack.safeEncode(this)'),
    );
  }

  Method _buildSafeToJson() {
    return Method(
      (m) => m
        ..name = 'safeToJson'
        ..returns = refer(
          '${_qualifyAckSymbol('SchemaResult')}<$_runtimeMapType>',
        )
        ..lambda = true
        ..body = const Code('safeToMap()'),
    );
  }

  Method _buildObjectFromRuntime(
    ModelInfo model,
    _ModelLookups lookups,
  ) {
    final arguments = <String>[
      for (final field in model.fields)
        '${field.name}: ${_decodeField(field, lookups)}',
      if (model.additionalProperties)
        'additionalProperties: ${_decodeAdditionalProperties(model)}',
    ];

    return Method(
      (m) => m
        ..name = '_fromAckRuntime'
        ..static = true
        ..returns = refer(model.className)
        ..requiredParameters.add(
          Parameter(
            (p) => p
              ..name = 'value'
              ..type = refer(_runtimeMapType),
          ),
        )
        ..body = Code('''
return ${model.className}(
  ${arguments.join(',\n  ')},
);'''),
    );
  }

  Method _buildObjectToRuntime(
    ModelInfo model,
    _ModelLookups lookups, {
    Map<String, String> extraEntries = const {},
  }) {
    final entries = <String>[
      if (model.additionalProperties) '...additionalProperties',
      for (final entry in extraEntries.entries)
        '${_stringLiteral(entry.key)}: ${entry.value}',
      for (final field in model.fields) _encodeFieldEntry(field, lookups),
    ];

    return Method(
      (m) => m
        ..name = '_toAckRuntime'
        ..returns = refer(_runtimeMapType)
        ..body = Code('''
return <String, Object?>{
  ${entries.join(',\n  ')},
};'''),
    );
  }

  String _decodeField(FieldInfo field, _ModelLookups lookups) {
    final read = 'value[${_stringLiteral(field.jsonKey)}]';
    final nullable = field.isNullable || !field.isRequired;
    final nonNull = _decodeNonNullField(field, lookups, read);

    if (!nullable) return nonNull;
    if (_isDirectCastField(field)) {
      final baseType = _baseFieldType(field, lookups);
      return '$read as $baseType?';
    }
    return '$read == null ? null : $nonNull';
  }

  String _decodeNonNullField(
    FieldInfo field,
    _ModelLookups lookups,
    String read,
  ) {
    if (field.nestedSchemaRef != null) {
      final typeName = _generatedModelName(field, lookups);
      final castType = _nestedCastType(field, lookups);
      return '$typeName.\$ack.fromRuntime($read as $castType)';
    }

    if (field.isList || field.isSet) {
      final elementType = _collectionElementType(field, lookups);
      if (_isGeneratedCollection(field, lookups)) {
        final castType = _collectionElementCastType(field, lookups);
        final converted =
            '($read as List).map((item) => '
            '$elementType.\$ack.fromRuntime(item as $castType))';
        return field.isSet
            ? '$converted.toSet()'
            : '$converted.toList(growable: false)';
      }
      return field.isSet
          ? '($read as List).cast<$elementType>().toSet()'
          : '($read as List).cast<$elementType>()';
    }

    if (field.isMap) {
      return 'Map<String, Object?>.from($read as Map)';
    }

    return '$read as ${_baseFieldType(field, lookups)}';
  }

  String _encodeFieldEntry(FieldInfo field, _ModelLookups lookups) {
    final key = _stringLiteral(field.jsonKey);
    final encoded = _encodeFieldValue(field, lookups);
    if (!field.isRequired) {
      return 'if (${field.name} != null) $key: $encoded';
    }
    return '$key: $encoded';
  }

  String _encodeFieldValue(FieldInfo field, _ModelLookups lookups) {
    final nullable = field.isNullable || !field.isRequired;
    final name = field.name;
    final nonNull = _encodeNonNullField(field, lookups, nullable ? '$name!' : name);
    if (!nullable) return nonNull;
    return '$name == null ? null : $nonNull';
  }

  String _encodeNonNullField(
    FieldInfo field,
    _ModelLookups lookups,
    String value,
  ) {
    if (field.nestedSchemaRef != null) {
      final typeName = _generatedModelName(field, lookups);
      return '$typeName.\$ack.toRuntime($value)';
    }

    if (field.isList || field.isSet) {
      if (_isGeneratedCollection(field, lookups)) {
        final elementType = _collectionElementType(field, lookups);
        return '$value.map((item) => '
            '$elementType.\$ack.toRuntime(item)).toList(growable: false)';
      }
      return field.isSet ? '$value.toList(growable: false)' : value;
    }

    return value;
  }

  String _decodeAdditionalProperties(ModelInfo model) {
    final knownKeys = model.fields.map((field) => field.jsonKey).toList();
    if (knownKeys.isEmpty) return 'Map.unmodifiable(value)';

    final keys = knownKeys.map(_stringLiteral).join(', ');
    return 'Map.unmodifiable(Map.fromEntries('
        'value.entries.where((entry) => '
        '!const <String>{$keys}.contains(entry.key))))';
  }

  String _fieldType(FieldInfo field, _ModelLookups lookups) {
    final base = _baseFieldType(field, lookups);
    if (field.isNullable || !field.isRequired) {
      return base.endsWith('?') ? base : '$base?';
    }
    return base;
  }

  String _baseFieldType(FieldInfo field, _ModelLookups lookups) {
    if (field.nestedSchemaRef != null) {
      return _generatedModelName(field, lookups);
    }

    if (field.type.isDartCoreString) return 'String';
    if (field.type.isDartCoreInt) return 'int';
    if (field.type.isDartCoreDouble) return 'double';
    if (field.type.isDartCoreBool) return 'bool';
    if (field.type.isDartCoreNum) return 'num';

    if (_isSpecialType(field.type) || field.isEnum) {
      return field.displayTypeOverride ??
          field.type.getDisplayString(withNullability: false);
    }

    if (field.isList) {
      return 'List<${_collectionElementType(field, lookups)}>';
    }
    if (field.isSet) {
      return 'Set<${_collectionElementType(field, lookups)}>';
    }
    if (field.isMap) return _runtimeMapType;

    if (field.displayTypeOverride != null) {
      return field.displayTypeOverride!;
    }

    return 'Object?';
  }

  String _generatedModelName(FieldInfo field, _ModelLookups lookups) {
    final override = field.displayTypeOverride;
    if (override != null) return _removeGeneratedTypeSuffix(override);

    final schemaName = field.nestedSchemaRef;
    final model = schemaName == null ? null : lookups.bySchemaName[schemaName];
    return model?.className ?? 'Object';
  }

  String _nestedCastType(FieldInfo field, _ModelLookups lookups) {
    final override = field.nestedSchemaCastTypeOverride;
    if (override != null) return override;

    final schemaName = field.nestedSchemaRef;
    final model = schemaName == null ? null : lookups.bySchemaName[schemaName];
    return model?.representationType ?? _runtimeMapType;
  }

  String _collectionElementType(
    FieldInfo field,
    _ModelLookups lookups,
  ) {
    final override = field.collectionElementDisplayTypeOverride;
    if (override != null) {
      return _isGeneratedCollection(field, lookups)
          ? _removeGeneratedTypeSuffix(override)
          : override;
    }

    final schemaRef = field.listElementSchemaRef;
    if (schemaRef != null) {
      final model = lookups.bySchemaName[schemaRef];
      if (model != null) return model.className;
    }

    final type = field.type;
    if (type is ParameterizedType && type.typeArguments.isNotEmpty) {
      return type.typeArguments.first.getDisplayString(
        withNullability: false,
      );
    }

    return 'Object?';
  }

  String _collectionElementCastType(
    FieldInfo field,
    _ModelLookups lookups,
  ) {
    final override = field.collectionElementCastTypeOverride;
    if (override != null) return override;

    final schemaRef = field.listElementSchemaRef;
    if (schemaRef != null) {
      final model = lookups.bySchemaName[schemaRef];
      if (model != null) return model.representationType;
    }

    return _runtimeMapType;
  }

  bool _isGeneratedCollection(
    FieldInfo field,
    _ModelLookups lookups,
  ) {
    if (field.collectionElementIsCustomType) return true;
    final schemaRef = field.listElementSchemaRef;
    return schemaRef != null && lookups.bySchemaName.containsKey(schemaRef);
  }

  bool _isDirectCastField(FieldInfo field) {
    return field.nestedSchemaRef == null &&
        !field.isList &&
        !field.isSet &&
        !field.isMap;
  }

  bool _isSpecialType(DartType type) {
    final element = type.element3;
    if (element is! InterfaceElement2) return false;
    final name = element.name3;
    final library = element.library2?.uri.toString();
    return library == 'dart:core' &&
        (name == 'DateTime' || name == 'Uri' || name == 'Duration');
  }

  String _removeGeneratedTypeSuffix(String name) {
    final separator = name.lastIndexOf('.');
    final prefix = separator < 0 ? '' : name.substring(0, separator + 1);
    final localName = separator < 0 ? name : name.substring(separator + 1);
    if (!localName.endsWith('Type')) return name;
    return '$prefix${localName.substring(0, localName.length - 4)}';
  }

  String _qualifyAckSymbol(String symbol) {
    final prefix = _ackImportPrefix;
    return prefix == null || prefix.isEmpty ? symbol : '$prefix.$symbol';
  }

  String _stringLiteral(String value) {
    final escaped = value
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'")
        .replaceAll(r'$', r'\$');
    return "'$escaped'";
  }
}
