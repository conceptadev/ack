import '../json/helper_names.dart';
import '../models/schema_model_graph.dart';

/// Emits class-first schema codecs and top-level JSON/runtime glue.
final class AckClassModelEmitter {
  const AckClassModelEmitter({this.ackPrefix});

  final String? ackPrefix;

  String emit(AckModelGraph graph) {
    final nodes = {for (final node in graph.nodes) node.id: node};
    final output = StringBuffer();
    for (final node in graph.nodes) {
      switch (node) {
        case AckObjectModelNode(:final unionId) when unionId != null:
          continue;
        case AckObjectModelNode():
          _emitObject(output, graph, node);
        case AckValueModelNode():
          throw StateError('Class-first graphs cannot contain value roots.');
        case AckUnionModelNode():
          for (final branchId in node.branches.values) {
            final branch = nodes[branchId];
            if (branch is! AckObjectModelNode) {
              throw StateError(
                'Class-first union branch $branchId is not an object.',
              );
            }
            _emitBranch(output, graph, branch);
          }
          _emitUnion(output, graph, node, nodes);
      }
    }
    return output.toString();
  }

  void _emitObject(
    StringBuffer output,
    AckModelGraph graph,
    AckObjectModelNode node,
  ) {
    final metadata = _metadata(graph, node);
    output
      ..writeln(_codecSchema(node, backingName: metadata.backingName))
      ..writeln()
      ..writeln(_facade(node.className, metadata))
      ..writeln()
      ..writeln(_fromRuntimeFunction(node))
      ..writeln()
      ..writeln(_toRuntimeFunction(node))
      ..writeln()
      ..writeln(_extension(node.className, metadata.facadeName))
      ..writeln()
      ..writeln(_fieldBridges(node));
  }

  void _emitBranch(
    StringBuffer output,
    AckModelGraph graph,
    AckObjectModelNode node,
  ) {
    final metadata = _metadata(graph, node);
    final rawName = ackClassRawObjectName(node.className);
    output
      ..writeln('final $rawName = ${_objectSchema(node)};')
      ..writeln()
      ..writeln(
        _codecSchema(node, backingName: metadata.backingName, input: rawName),
      )
      ..writeln()
      ..writeln(_facade(node.className, metadata))
      ..writeln()
      ..writeln(_fromRuntimeFunction(node))
      ..writeln()
      ..writeln(_toRuntimeFunction(node))
      ..writeln()
      ..writeln(_extension(node.className, metadata.facadeName))
      ..writeln()
      ..writeln(_fieldBridges(node));
  }

  void _emitUnion(
    StringBuffer output,
    AckModelGraph graph,
    AckUnionModelNode node,
    Map<AckSchemaId, AckModelNode> nodes,
  ) {
    final metadata = _metadata(graph, node);
    final schemaEntries = <String>[];
    final decodeCases = <String>[];
    final encodeCases = <String>[];
    for (final entry in node.branches.entries) {
      final branch = nodes[entry.value]!;
      schemaEntries.add(
        '${_literal(entry.key)}: ${ackClassRawObjectName(branch.className)}',
      );
      decodeCases.add(
        '${_literal(entry.key)} => '
        '${ackClassFromRuntimeName(branch.className)}(value)',
      );
      encodeCases.add(
        '${branch.className}() => '
        '${ackClassToRuntimeName(branch.className)}(model)',
      );
    }
    output
      ..writeln('''
final ${metadata.backingName} = ${_ack('Ack')}.discriminated(
  discriminatorKey: ${_literal(node.discriminatorKey)},
  schemas: {${schemaEntries.join(', ')}},
).codec<${node.className}>(
  decode: (value) => switch (value[${_literal(node.discriminatorKey)}]) {
    ${decodeCases.join(',\n    ')},
    final unknown => throw StateError(
      'Unknown ${node.discriminatorKey}: \$unknown',
    ),
  },
  encode: (model) => switch (model) {
    ${encodeCases.join(',\n    ')},
  },
);''')
      ..writeln()
      ..writeln(_facade(node.className, metadata))
      ..writeln()
      ..writeln(_extension(node.className, metadata.facadeName))
      ..writeln();
  }

  String _codecSchema(
    AckObjectModelNode node, {
    required String backingName,
    String? input,
  }) {
    final expression = input ?? _objectSchema(node);
    return '''
final $backingName = $expression.codec<${node.className}>(
  decode: ${ackClassFromRuntimeName(node.className)},
  encode: ${ackClassToRuntimeName(node.className)},
);''';
  }

  String _facade(String className, AckClassModelMetadata metadata) =>
      '''
abstract final class ${metadata.facadeName} {
  static ${_ack('AckSchema')}<Map<String, Object?>, $className> get schema =>
      ${metadata.backingName};

  static $className parse(Object? value, {String? debugName}) =>
      ${metadata.backingName}.parse(value, debugName: debugName)!;

  static ${_ack('SchemaResult')}<$className> safeParse(
    Object? value, {
    String? debugName,
  }) => ${metadata.backingName}.safeParse(value, debugName: debugName);

  static $className fromJson(Map<String, dynamic> json) => parse(json);

  static Map<String, Object?> encode(
    $className value, {
    String? debugName,
  }) => ${metadata.backingName}.encode(value, debugName: debugName)!;

  static ${_ack('SchemaResult')}<Map<String, Object?>> safeEncode(
    $className value, {
    String? debugName,
  }) => ${metadata.backingName}.safeEncode(value, debugName: debugName);

  static Map<String, Object?> toJsonSchema() =>
      ${metadata.backingName}.toJsonSchema();

  static ${_ack('AckSchemaModel')} toSchemaModel() =>
      ${_ack('AckSchemaModelExtension')}(${metadata.backingName}).toSchemaModel();
}''';

  String _objectSchema(AckObjectModelNode node) {
    final entries = [
      for (final field in node.fields)
        '${_literal(field.jsonKey)}: ${field.schemaExpression}',
    ];
    final additional = node.additionalProperties
        ? ', additionalProperties: true'
        : '';
    return '${_ack('Ack')}.object({${entries.join(', ')}}$additional)';
  }

  String _fromRuntimeFunction(AckObjectModelNode node) {
    final helper = jsonFromHelperName(node.className);
    final function = ackClassFromRuntimeName(node.className);
    if (!node.additionalProperties) {
      return '''
${node.className} $function(Map<String, Object?> value) =>
    $helper(Map<String, dynamic>.from(value));''';
    }
    final declared = _declaredKeys(node);
    return '''
${node.className} $function(Map<String, Object?> value) {
  const declared = ${_keySet(declared)};
  return $helper(<String, dynamic>{
    ...value,
    'additionalProperties': Map<String, Object?>.fromEntries(
      value.entries.where((entry) => !declared.contains(entry.key)),
    ),
  });
}''';
  }

  String _toRuntimeFunction(AckObjectModelNode node) {
    final function = ackClassToRuntimeName(node.className);
    final jsonHelper = jsonToHelperName(node.className);
    final requiredNulls = [
      for (final field in node.fields)
        if (field.isRequired && field.nullable) field,
    ];
    final discriminatorKey = node.discriminatorKey;
    final discriminatorValue = node.discriminatorValue;
    final needsBlock =
        node.additionalProperties ||
        requiredNulls.isNotEmpty ||
        discriminatorKey != null;
    if (!needsBlock) {
      return '''
Map<String, Object?> $function(${node.className} model) =>
    <String, Object?>{...$jsonHelper(model)};''';
    }

    final lines = <String>[];
    if (node.additionalProperties) {
      lines.add('const declared = ${_keySet(_declaredKeys(node))};');
    }
    lines
      ..add('final result = <String, Object?>{...$jsonHelper(model)};')
      ..addAll([
        if (node.additionalProperties) "result.remove('additionalProperties');",
        for (final field in requiredNulls)
          'if (model.${field.dartName} == null) { '
              'result[${_literal(field.jsonKey)}] = null; }',
      ]);

    final entries = <String>[
      if (node.additionalProperties)
        'for (final entry in model.additionalProperties.entries)\n'
            '    if (!declared.contains(entry.key)) entry.key: entry.value',
      '...result',
      if (discriminatorKey != null && discriminatorValue != null)
        '${_literal(discriminatorKey)}: ${_literal(discriminatorValue)}',
    ];
    lines.add('return <String, Object?>{${entries.join(',\n  ')}};');
    return '''
Map<String, Object?> $function(${node.className} model) {
  ${lines.join('\n  ')}
}''';
  }

  String _extension(String className, String facadeName) =>
      '''
extension ${ackClassExtensionName(className)} on $className {
  Map<String, dynamic> toJson() =>
      Map<String, dynamic>.from($facadeName.encode(this));

  ${_ack('SchemaResult')}<Map<String, Object?>> safeToJson() =>
      $facadeName.safeEncode(this);
}''';

  String _fieldBridges(AckObjectModelNode node) {
    final output = StringBuffer();
    for (final field in node.fields) {
      final type = _type(field.runtimeRef);
      final fromType = field.defaultExpression == null || field.nullable
          ? type
          : '$type?';
      final fromName = ackClassFromRuntimeBridgeName(
        node.className,
        field.dartName,
      );
      final toName = ackClassToRuntimeBridgeName(
        node.className,
        field.dartName,
      );
      output
        ..writeln(
          '$fromType $fromName(Object? value) => '
          '${_fromRuntime(field.runtimeRef, 'value')};',
        )
        ..writeln(
          'Object? $toName($type value) => '
          '${_toRuntime(field.runtimeRef, 'value')};',
        );
    }
    if (node.additionalProperties) {
      final fromName = ackClassFromRuntimeBridgeName(
        node.className,
        'additionalProperties',
      );
      final toName = ackClassToRuntimeBridgeName(
        node.className,
        'additionalProperties',
      );
      output
        ..writeln(
          'Map<String, Object?>? $fromName(Object? value) => '
          'value as Map<String, Object?>?;',
        )
        ..writeln('Object? $toName(Map<String, Object?> value) => value;');
    }
    return output.toString();
  }

  String _fromRuntime(AckTypeRef type, String expression) => switch (type) {
    AckNullableTypeRef(:final inner)
        when inner is AckScalarTypeRef || inner is AckExternalTypeRef =>
      '$expression as ${_type(type)}',
    AckNullableTypeRef(:final inner) =>
      '$expression == null ? null : '
          '${_fromRuntime(inner, expression)}',
    AckModelTypeRef(:final runtimeRef, :final visibleName) =>
      '$visibleName.\$ack.fromRuntime('
          '$expression as ${_type(runtimeRef)})',
    AckListTypeRef(:final elementType) =>
      '($expression as List).map((item) => '
          '${_fromRuntime(elementType, 'item')}).toList()',
    AckSetTypeRef(:final elementType) =>
      '($expression as Set).map((item) => '
          '${_fromRuntime(elementType, 'item')}).toSet()',
    AckMapTypeRef(:final valueType) =>
      '($expression as Map).map((key, item) => MapEntry('
          'key as String, ${_fromRuntime(valueType, 'item')}))',
    _ => '$expression as ${_type(type)}',
  };

  String _toRuntime(AckTypeRef type, String expression) => switch (type) {
    AckNullableTypeRef(:final inner)
        when inner is AckScalarTypeRef || inner is AckExternalTypeRef =>
      expression,
    AckNullableTypeRef(:final inner) =>
      '$expression == null ? null : ${_toRuntime(inner, expression)}',
    AckModelTypeRef(:final visibleName) =>
      '$visibleName.\$ack.toRuntime($expression)',
    AckListTypeRef(:final elementType) =>
      '$expression.map((item) => ${_toRuntime(elementType, 'item')})'
          '.toList(growable: false)',
    AckSetTypeRef(:final elementType) =>
      '$expression.map((item) => ${_toRuntime(elementType, 'item')}).toSet()',
    AckMapTypeRef(:final valueType) =>
      '$expression.map((key, item) => '
          'MapEntry(key, ${_toRuntime(valueType, 'item')}))',
    _ => expression,
  };

  String _type(AckTypeRef type) => switch (type) {
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

  Set<String> _declaredKeys(AckObjectModelNode node) => {
    for (final field in node.fields) field.jsonKey,
    if (node.discriminatorKey case final discriminator?) discriminator,
  };

  String _keySet(Set<String> keys) =>
      '<String>{${keys.map(_literal).join(', ')}}';

  AckClassModelMetadata _metadata(AckModelGraph graph, AckModelNode node) {
    final metadata = graph.classMetadataFor(node.id);
    if (metadata == null) {
      throw StateError('Missing class-first metadata for ${node.id}.');
    }
    return metadata;
  }

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
}
