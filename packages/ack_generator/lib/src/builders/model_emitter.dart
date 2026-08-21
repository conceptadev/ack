import 'package:code_builder/code_builder.dart';

import '../models/schema_model_graph.dart';

/// Emits immutable model declarations solely from a normalized model graph.
final class AckModelEmitter {
  AckModelEmitter({this.ackPrefix});

  final String? ackPrefix;

  List<Spec> emit(AckModelGraph graph) {
    final nodes = {for (final node in graph.nodes) node.id: node};
    final output = <Spec>[];
    for (final node in graph.nodes) {
      switch (node) {
        case AckObjectModelNode(:final unionId) when unionId != null:
          continue;
        case AckObjectModelNode():
          output.add(_object(node));
        case AckValueModelNode():
          output.add(_value(node));
        case AckUnionModelNode():
          output.add(_union(node, nodes));
          for (final branchId in node.branches.values) {
            final branch = nodes[branchId];
            if (branch is AckObjectModelNode) {
              output.add(_branch(branch, node));
            }
          }
      }
    }
    final needsDynamicMapCopy = graph.nodes.whereType<AckObjectModelNode>().any(
      (node) => node.additionalProperties,
    );
    if (needsDynamicMapCopy) {
      output.addAll([_immutableValueHelper(), _immutableMapHelper()]);
    }
    return output;
  }

  Class _object(AckObjectModelNode node) {
    return Class(
      (b) => b
        ..name = node.className
        ..modifier = ClassModifier.final$
        ..docs.addAll(_docs(node, 'Immutable model'))
        ..fields.addAll([
          for (final field in node.fields) _field(field),
          if (node.additionalProperties) _additionalPropertiesField(),
          _adapter(node, node.id.declarationName),
        ])
        ..constructors.addAll([
          _objectConstructor(node.fields, node.additionalProperties),
          _parseFactory(),
          _fromJsonFactory(_objectJsonType),
        ])
        ..methods.addAll([
          _safeParse(node.className),
          _objectToJson(),
          _objectSafeToJson(),
          _objectFromRuntime(node),
          _objectToRuntime(node),
        ]),
    );
  }

  Class _value(AckValueModelNode node) {
    final runtimeRef = _type(node.runtimeRef);
    final boundaryType = _type(node.boundaryType);
    return Class(
      (b) => b
        ..name = node.className
        ..modifier = ClassModifier.final$
        ..docs.addAll(_docs(node, 'Immutable value model'))
        ..fields.addAll([
          Field(
            (f) => f
              ..name = 'value'
              ..modifier = FieldModifier.final$
              ..type = refer(runtimeRef),
          ),
          _adapter(node, node.id.declarationName),
        ])
        ..constructors.addAll([
          _valueConstructor(node, runtimeRef),
          _parseFactory(),
          _fromJsonFactory(boundaryType),
        ])
        ..methods.addAll([
          _safeParse(node.className),
          Method(
            (m) => m
              ..name = 'toJson'
              ..returns = refer(boundaryType)
              ..lambda = true
              ..body = const Code(r'$ack.encode(this)'),
          ),
          Method(
            (m) => m
              ..name = 'safeToJson'
              ..returns = refer('${_ack('SchemaResult')}<$boundaryType>')
              ..lambda = true
              ..body = const Code(r'$ack.safeEncode(this)'),
          ),
          Method(
            (m) => m
              ..name = '_fromAckRuntime'
              ..static = true
              ..returns = refer(node.className)
              ..requiredParameters.add(
                Parameter(
                  (p) => p
                    ..name = 'value'
                    ..type = refer(runtimeRef),
                ),
              )
              ..lambda = true
              ..body = Code('${node.className}(value)'),
          ),
          Method(
            (m) => m
              ..name = '_toAckRuntime'
              ..returns = refer(runtimeRef)
              ..lambda = true
              ..body = const Code('value'),
          ),
        ]),
    );
  }

  Class _union(AckUnionModelNode node, Map<AckSchemaId, AckModelNode> nodes) {
    final cases = <String>[];
    for (final entry in node.branches.entries) {
      final branch = nodes[entry.value]!;
      cases.add(
        '${_literal(entry.key)} => ${branch.className}._fromAckRuntime(value)',
      );
    }
    return Class(
      (b) => b
        ..name = node.className
        ..sealed = true
        ..docs.addAll(_docs(node, 'Discriminated model base'))
        ..fields.add(_adapter(node, node.id.declarationName))
        ..constructors.addAll([
          Constructor((c) => c.constant = true),
          _parseFactory(),
          _fromJsonFactory(_objectJsonType),
        ])
        ..methods.addAll([
          _safeParse(node.className),
          Method(
            (m) => m
              ..type = MethodType.getter
              ..name = node.discriminatorKey
              ..returns = refer('String'),
          ),
          _objectToJson(),
          _objectSafeToJson(),
          Method(
            (m) => m
              ..name = '_fromAckRuntime'
              ..static = true
              ..returns = refer(node.className)
              ..requiredParameters.add(
                Parameter(
                  (p) => p
                    ..name = 'value'
                    ..type = refer(_runtimeMapType),
                ),
              )
              ..body = Code('''
return switch (value[${_literal(node.discriminatorKey)}]) {
  ${cases.join(',\n  ')},
  final unknown => throw StateError(
    'Unknown ${node.discriminatorKey}: \$unknown',
  ),
};'''),
          ),
          Method(
            (m) => m
              ..name = '_toAckRuntime'
              ..returns = refer(_runtimeMapType),
          ),
        ]),
    );
  }

  Class _branch(AckObjectModelNode node, AckUnionModelNode union) {
    final discriminator = node.discriminatorKey!;
    final value = node.discriminatorValue!;
    final fields = node.fields
        .where((field) => field.jsonKey != discriminator)
        .toList();
    return Class(
      (b) => b
        ..name = node.className
        ..modifier = ClassModifier.final$
        ..extend = refer(union.className)
        ..docs.addAll(_docs(node, 'Discriminated model branch'))
        ..fields.addAll([
          for (final field in fields) _field(field),
          if (node.additionalProperties) _additionalPropertiesField(),
          _adapter(
            node,
            '${union.id.declarationName}.effectiveBranch(${_literal(value)})',
          ),
        ])
        ..constructors.addAll([
          _objectConstructor(fields, node.additionalProperties),
          _parseFactory(),
          _fromJsonFactory(_objectJsonType),
        ])
        ..methods.addAll([
          _safeParse(node.className),
          Method(
            (m) => m
              ..annotations.add(refer('override'))
              ..type = MethodType.getter
              ..name = discriminator
              ..returns = refer('String')
              ..lambda = true
              ..body = Code(_literal(value)),
          ),
          _objectFromRuntime(
            node,
            fields: fields,
            additionalKnownKeys: {discriminator},
          ),
          _objectToRuntime(
            node,
            fields: fields,
            leadingEntries: {discriminator: _literal(value)},
            isOverride: true,
          ),
        ]),
    );
  }

  Field _field(AckFieldNode field) => Field(
    (f) => f
      ..name = field.dartName
      ..modifier = FieldModifier.final$
      ..type = refer(_fieldType(field))
      ..docs.addAll([
        if (field.description != null) '/// ${field.description}',
      ]),
  );

  Field _additionalPropertiesField() => Field(
    (f) => f
      ..name = 'additionalProperties'
      ..modifier = FieldModifier.final$
      ..type = refer(_runtimeMapType)
      ..docs.add(
        '/// Properties accepted by a schema with additional properties.',
      ),
  );

  Field _adapter(AckModelNode node, String schemaExpression) => Field(
    (f) => f
      ..name = r'$ack'
      ..static = true
      ..modifier = FieldModifier.final$
      ..assignment = Code('''
${_ack('AckModelAdapter')}(
  schema: () => $schemaExpression,
  fromRuntime: ${node.className}._fromAckRuntime,
  toRuntime: (model) => model._toAckRuntime(),
)'''),
  );

  Constructor _objectConstructor(
    List<AckFieldNode> fields,
    bool additionalProperties,
  ) => Constructor((c) {
    for (final field in fields) {
      final copyType = _nonNullable(field.runtimeRef);
      final needsCopy = _requiresImmutableCopy(copyType);
      c.optionalParameters.add(
        Parameter(
          (p) => p
            ..name = field.dartName
            ..named = true
            ..required = field.isRequired
            ..toThis = !needsCopy
            ..type = needsCopy ? refer(_fieldType(field)) : null,
        ),
      );
      if (!needsCopy) continue;

      final value = field.dartName;
      final copy = _immutableCopy(copyType, value);
      var initializer = copy;
      if (!field.isRequired || field.nullable) {
        initializer =
            'switch ($value) {'
            ' null => null,'
            ' final fieldValue => ${_immutableCopy(copyType, 'fieldValue')},'
            ' }';
      }
      c.initializers.add(Code('${field.dartName} = $initializer'));
    }
    if (additionalProperties) {
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
          'additionalProperties = _ackImmutableCopyMap(additionalProperties)',
        ),
      );
    }
  });

  Constructor _valueConstructor(AckValueModelNode node, String runtimeType) {
    final needsCopy = _requiresImmutableCopy(node.runtimeRef);
    return Constructor((c) {
      c.requiredParameters.add(
        Parameter(
          (p) => p
            ..name = 'value'
            ..toThis = !needsCopy
            ..type = needsCopy ? refer(runtimeType) : null,
        ),
      );
      if (needsCopy) {
        c.initializers.add(
          Code('value = ${_immutableCopy(node.runtimeRef, 'value')}'),
        );
      }
    });
  }

  Constructor _parseFactory() => Constructor(
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

  Constructor _fromJsonFactory(String boundaryType) => Constructor(
    (c) => c
      ..factory = true
      ..name = 'fromJson'
      ..requiredParameters.add(
        Parameter(
          (p) => p
            ..name = 'json'
            ..type = refer(boundaryType),
        ),
      )
      ..body = const Code(r'return $ack.parse(json);'),
  );

  Method _safeParse(String className) => Method(
    (m) => m
      ..name = 'safeParse'
      ..static = true
      ..returns = refer('${_ack('SchemaResult')}<$className>')
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

  Method _objectToJson() => Method(
    (m) => m
      ..name = 'toJson'
      ..returns = refer(_objectJsonType)
      ..lambda = true
      ..body = const Code('Map<String, dynamic>.from(\$ack.encode(this))'),
  );

  Method _objectSafeToJson() => Method(
    (m) => m
      ..name = 'safeToJson'
      ..returns = refer('${_ack('SchemaResult')}<$_runtimeMapType>')
      ..lambda = true
      ..body = const Code(r'$ack.safeEncode(this)'),
  );

  Method _objectFromRuntime(
    AckObjectModelNode node, {
    List<AckFieldNode>? fields,
    Set<String> additionalKnownKeys = const {},
  }) {
    final effectiveFields = fields ?? node.fields;
    final arguments = <String>[
      for (final field in effectiveFields)
        '${field.dartName}: ${_decodeField(field)}',
      if (node.additionalProperties)
        'additionalProperties: ${_additionalPropertiesDecode(effectiveFields, additionalKnownKeys)}',
    ];
    return Method(
      (m) => m
        ..name = '_fromAckRuntime'
        ..static = true
        ..returns = refer(node.className)
        ..requiredParameters.add(
          Parameter(
            (p) => p
              ..name = 'value'
              ..type = refer(_runtimeMapType),
          ),
        )
        ..body = Code('''
return ${node.className}(
  ${arguments.join(',\n  ')}${arguments.isEmpty ? '' : ','}
);'''),
    );
  }

  Method _objectToRuntime(
    AckObjectModelNode node, {
    List<AckFieldNode>? fields,
    Map<String, String> leadingEntries = const {},
    bool isOverride = false,
  }) {
    final effectiveFields = fields ?? node.fields;
    final entries = <String>[
      if (node.additionalProperties) '...additionalProperties',
      for (final entry in leadingEntries.entries)
        '${_literal(entry.key)}: ${entry.value}',
      for (final field in effectiveFields) _encodeField(field),
    ];
    return Method((m) {
      m
        ..name = '_toAckRuntime'
        ..returns = refer(_runtimeMapType)
        ..body = Code('''
return <String, Object?>{
  ${entries.join(',\n  ')}${entries.isEmpty ? '' : ','}
};''');
      if (isOverride) m.annotations.add(refer('override'));
    });
  }

  String _decodeField(AckFieldNode field) {
    final read = 'value[${_literal(field.jsonKey)}]';
    final decoded = _fromRuntime(field.runtimeRef, read);
    if (field.isRequired && !field.nullable) return decoded;

    final runtimeRef = _nonNullable(field.runtimeRef);
    if (!_requiresRuntimeConversion(runtimeRef)) {
      return '$read as ${_type(runtimeRef)}?';
    }
    return 'switch ($read) {'
        ' null => null,'
        ' final fieldValue => ${_fromRuntime(runtimeRef, 'fieldValue')},'
        ' }';
  }

  String _encodeField(AckFieldNode field) {
    final runtimeRef = _nonNullable(field.runtimeRef);
    if (field.presence == AckFieldPresence.optional) {
      return 'if (${field.dartName} != null) ${_literal(field.jsonKey)}: ${_toRuntime(runtimeRef, '${field.dartName}!')}';
    }
    if (field.nullable && _requiresRuntimeConversion(runtimeRef)) {
      return '${_literal(field.jsonKey)}: switch (${field.dartName}) {'
          ' null => null,'
          ' final fieldValue => ${_toRuntime(runtimeRef, 'fieldValue')},'
          ' }';
    }
    return '${_literal(field.jsonKey)}: ${_toRuntime(runtimeRef, field.dartName)}';
  }

  String _additionalPropertiesDecode(
    List<AckFieldNode> fields,
    Set<String> additionalKnownKeys,
  ) {
    final keys = {
      ...additionalKnownKeys,
      for (final field in fields) field.jsonKey,
    };
    if (keys.isEmpty) return '_ackImmutableCopyMap(value)';
    return '_ackImmutableCopyMap(Map<String, Object?>.fromEntries('
        'value.entries.where((entry) => !const <String>{'
        '${keys.map(_literal).join(', ')}'
        '}.contains(entry.key))))';
  }

  String _fromRuntime(AckTypeRef type, String expression) {
    return switch (type) {
      AckNullableTypeRef(:final inner) =>
        '$expression == null ? null : ${_fromRuntime(inner, '$expression!')}',
      AckModelTypeRef(:final runtimeRef, :final visibleName) =>
        '$visibleName.\$ack.fromRuntime($expression as ${_type(runtimeRef)})',
      AckListTypeRef(:final elementType) =>
        'List<${_type(elementType)}>.unmodifiable(($expression as List).map((item) => ${_fromRuntime(elementType, 'item')}))',
      AckSetTypeRef(:final elementType) =>
        'Set<${_type(elementType)}>.unmodifiable(($expression as Set).map((item) => ${_fromRuntime(elementType, 'item')}))',
      AckMapTypeRef(:final valueType) =>
        'Map<String, ${_type(valueType)}>.unmodifiable(($expression as Map).map((key, item) => MapEntry(key as String, ${_fromRuntime(valueType, 'item')})))',
      _ => '$expression as ${_type(type)}',
    };
  }

  String _toRuntime(AckTypeRef type, String expression) {
    return switch (type) {
      AckNullableTypeRef(:final inner) =>
        '$expression == null ? null : ${_toRuntime(inner, '$expression!')}',
      AckModelTypeRef(:final visibleName) =>
        '$visibleName.\$ack.toRuntime($expression)',
      AckListTypeRef(:final elementType) =>
        '$expression.map((item) => ${_toRuntime(elementType, 'item')}).toList(growable: false)',
      AckSetTypeRef(:final elementType) =>
        '$expression.map((item) => ${_toRuntime(elementType, 'item')}).toSet()',
      AckMapTypeRef(:final valueType) =>
        '$expression.map((key, item) => MapEntry(key, ${_toRuntime(valueType, 'item')}))',
      _ => expression,
    };
  }

  String _immutableCopy(AckTypeRef type, String expression) {
    return switch (type) {
      AckNullableTypeRef(:final inner) =>
        '$expression == null ? null : ${_immutableCopy(inner, '$expression!')}',
      AckListTypeRef(:final elementType) =>
        'List<${_type(elementType)}>.unmodifiable($expression.map((item) => ${_immutableCopy(elementType, 'item')}))',
      AckSetTypeRef(:final elementType) =>
        'Set<${_type(elementType)}>.unmodifiable($expression.map((item) => ${_immutableCopy(elementType, 'item')}))',
      AckMapTypeRef(:final valueType) =>
        'Map<String, ${_type(valueType)}>.unmodifiable($expression.map((key, item) => MapEntry(key, ${_immutableCopy(valueType, 'item')})))',
      _ => expression,
    };
  }

  String _fieldType(AckFieldNode field) {
    final base = _type(field.runtimeRef);
    if (field.isRequired && !field.nullable) return base;
    return field.runtimeRef is AckNullableTypeRef ? base : '$base?';
  }

  AckTypeRef _nonNullable(AckTypeRef type) => switch (type) {
    AckNullableTypeRef(:final inner) => inner,
    _ => type,
  };

  bool _requiresImmutableCopy(AckTypeRef type) => switch (type) {
    AckNullableTypeRef(:final inner) => _requiresImmutableCopy(inner),
    AckListTypeRef() || AckSetTypeRef() || AckMapTypeRef() => true,
    _ => false,
  };

  bool _requiresRuntimeConversion(AckTypeRef type) => switch (type) {
    AckNullableTypeRef(:final inner) => _requiresRuntimeConversion(inner),
    AckModelTypeRef() ||
    AckListTypeRef() ||
    AckSetTypeRef() ||
    AckMapTypeRef() => true,
    _ => false,
  };

  String _type(AckTypeRef type) {
    return switch (type) {
      AckNullableTypeRef(:final inner) => '${_type(inner)}?',
      AckScalarTypeRef(:final dartType) => dartType,
      AckExternalTypeRef(:final visibleName, :final typeArguments) =>
        typeArguments.isEmpty
            ? visibleName
            : '$visibleName<${typeArguments.map(_type).join(', ')}>',
      AckModelTypeRef(:final visibleName) => visibleName,
      AckListTypeRef(:final elementType) => 'List<${_type(elementType)}>',
      AckSetTypeRef(:final elementType) => 'Set<${_type(elementType)}>',
      AckMapTypeRef(:final valueType) => 'Map<String, ${_type(valueType)}>',
    };
  }

  Method _immutableValueHelper() => Method(
    (m) => m
      ..name = '_ackImmutableCopyValue'
      ..returns = refer('Object?')
      ..requiredParameters.add(
        Parameter(
          (p) => p
            ..name = 'value'
            ..type = refer('Object?'),
        ),
      )
      ..lambda = true
      ..body = const Code('''
switch (value) {
  List() => List.unmodifiable(value.map(_ackImmutableCopyValue)),
  Set() => Set.unmodifiable(value.map(_ackImmutableCopyValue)),
  Map() => Map.unmodifiable(
      value.map((key, item) => MapEntry(key, _ackImmutableCopyValue(item))),
    ),
  _ => value,
}'''),
  );

  Method _immutableMapHelper() => Method(
    (m) => m
      ..name = '_ackImmutableCopyMap'
      ..returns = refer(_runtimeMapType)
      ..requiredParameters.add(
        Parameter(
          (p) => p
            ..name = 'value'
            ..type = refer(_runtimeMapType),
        ),
      )
      ..lambda = true
      ..body = const Code('''
Map.unmodifiable(
  value.map(
    (key, item) => MapEntry(key, _ackImmutableCopyValue(item)),
  ),
)'''),
  );

  List<String> _docs(AckModelNode node, String kind) => [
    '/// $kind generated from `${node.id.declarationName}`.',
    if (node.description != null) '/// ${node.description}',
  ];

  String _ack(String symbol) {
    final prefix = ackPrefix;
    return prefix == null || prefix.isEmpty ? symbol : '$prefix.$symbol';
  }

  String _literal(String value) {
    final escaped = value
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'")
        .replaceAll(r'$', r'\$');
    return "'$escaped'";
  }

  static const _runtimeMapType = 'Map<String, Object?>';
  static const _objectJsonType = 'Map<String, dynamic>';
}
