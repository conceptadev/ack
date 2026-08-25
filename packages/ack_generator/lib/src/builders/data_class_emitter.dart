import '../models/schema_model_graph.dart';

/// Shared copy/equality/hash/string emission for class-first and schema-first
/// data classes.
final class AckDataClassEmitter {
  const AckDataClassEmitter({this.ackPrefix});

  final String? ackPrefix;

  /// Private mixin applied by a hand-written `@AckModel` class.
  String mixin({
    required String className,
    required String facadeName,
    required List<AckFieldNode> fields,
    required List<AckConstructorParameter> constructorParameters,
    required bool includeValueMembers,
    String? captureFieldName,
  }) {
    final stored = [
      ...fields,
      if (captureFieldName != null)
        AckFieldNode(
          dartName: captureFieldName,
          jsonKey: captureFieldName,
          presence: AckSchemaFieldPresence.required,
          nullable: false,
          runtimeRef: const AckMapTypeRef(
            AckNullableTypeRef(AckScalarTypeRef('Object')),
          ),
        ),
    ];
    final members = [
      if (includeValueMembers) ...[
        copyWithMethod(
          className: className,
          fields: stored,
          constructorParameters: constructorParameters,
          castSelf: true,
        ),
        equalityMembers(className: className, fields: stored, castSelf: true),
        toStringMethod(className: className, fields: stored, castSelf: true),
      ],
      jsonMembers(className: className, facadeName: facadeName),
    ];
    return '''
mixin ${'_\$${className}Ack'} {
  ${members.join('\n\n  ')}
}''';
  }

  String copyWithMethod({
    required String className,
    required List<AckFieldNode> fields,
    required List<AckConstructorParameter> constructorParameters,
    bool castSelf = false,
  }) {
    final byField = {for (final field in fields) field.dartName: field};
    final receiver = castSelf ? 'self' : 'this';
    final parameters = [
      for (final parameter in constructorParameters)
        '${_copyWithType(byField[parameter.fieldName] ?? _synthetic(parameter))} ${parameter.name}',
    ];
    final arguments = [
      for (final parameter in constructorParameters)
        parameter.kind == AckConstructorParameterKind.named
            ? '${parameter.name}: ${parameter.name} ?? $receiver.${parameter.fieldName}'
            : '${parameter.name} ?? $receiver.${parameter.fieldName}',
    ];
    final parameterList = parameters.isEmpty
        ? ''
        : '{${parameters.join(', ')}}';
    if (castSelf) {
      return '''
$className copyWith($parameterList) {
  final self = this as $className;
  return $className(${arguments.join(', ')});
}''';
    }
    return '''
$className copyWith($parameterList) => $className(${arguments.join(', ')});''';
  }

  String equalityMembers({
    required String className,
    required List<AckFieldNode> fields,
    bool castSelf = false,
  }) {
    final hashes = [
      'runtimeType',
      for (final field in fields)
        _hash('${castSelf ? 'self' : 'this'}.${field.dartName}'),
    ];
    if (castSelf) {
      final fieldEquals = [
        for (final field in fields)
          _equals('self.${field.dartName}', 'other.${field.dartName}'),
      ];
      final equality = fieldEquals.isEmpty ? 'true' : fieldEquals.join(' && ');
      return '''
@override
bool operator ==(Object other) {
  if (identical(this, other)) return true;
  if (other is! $className || runtimeType != other.runtimeType) return false;
  final self = this as $className;
  return $equality;
}

@override
int get hashCode {
  final self = this as $className;
  return Object.hashAll([${hashes.join(', ')}]);
}''';
    }
    final comparisons = [
      'other is $className',
      'runtimeType == other.runtimeType',
      for (final field in fields)
        _equals('this.${field.dartName}', 'other.${field.dartName}'),
    ];
    return '''
@override
bool operator ==(Object other) =>
    identical(this, other) || (${comparisons.join(' && ')});

@override
int get hashCode => Object.hashAll([${hashes.join(', ')}]);''';
  }

  String toStringMethod({
    required String className,
    required List<AckFieldNode> fields,
    bool castSelf = false,
  }) {
    if (castSelf) {
      final parts = [
        for (final field in fields)
          '${field.dartName}: \${self.${field.dartName}}',
      ];
      return '''
@override
String toString() {
  final self = this as $className;
  return '$className(${parts.join(', ')})';
}''';
    }
    final parts = [
      for (final field in fields) '${field.dartName}: \$${field.dartName}',
    ];
    return '''
@override
String toString() => '$className(${parts.join(', ')})';''';
  }

  String jsonMembers({required String className, required String facadeName}) {
    return '''
Map<String, dynamic> toJson() =>
    Map<String, dynamic>.from($facadeName.encode(this as $className));

${_ack('SchemaResult')}<Map<String, Object?>> safeToJson() =>
    $facadeName.safeEncode(this as $className);''';
  }

  String fieldDartType(AckFieldNode field) {
    final base = _type(field.runtimeRef);
    if (field.isRequired && !field.nullable) return base;
    return base.endsWith('?') ? base : '$base?';
  }

  String _copyWithType(AckFieldNode field) {
    final type = fieldDartType(field);
    return type.endsWith('?') ? type : '$type?';
  }

  AckFieldNode _synthetic(AckConstructorParameter parameter) => AckFieldNode(
    dartName: parameter.fieldName,
    jsonKey: parameter.fieldName,
    presence: AckSchemaFieldPresence.required,
    nullable: parameter.typeRef is AckNullableTypeRef,
    runtimeRef: parameter.typeRef,
  );

  String _equals(String left, String right) =>
      '${_ack('deepEquals')}($left, $right)';

  String _hash(String expression) => '${_ack('deepHashCode')}($expression)';

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

  String _ack(String symbol) {
    final prefix = ackPrefix;
    return prefix == null || prefix.isEmpty ? symbol : '$prefix.$symbol';
  }
}
