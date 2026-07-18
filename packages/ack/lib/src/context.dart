import 'package:meta/meta.dart';

import 'schemas/schema.dart';

/// Represents the context in which a schema operation is occurring.
@immutable
class SchemaContext {
  final String name;
  final Object? value;
  final AnyAckSchema schema;
  final SchemaContext? parent;

  /// String segment used by the legacy JSON Pointer-style [path].
  final String? pathSegment;

  /// Raw property key represented by this context.
  ///
  /// Object properties use string keys, list items use integer indexes, and
  /// transparent wrapper branches use `''`. Defaults to [pathSegment].
  final Object? pathKey;
  final SchemaOperation operation;

  const SchemaContext({
    required this.name,
    required this.schema,
    required this.value,
    this.parent,
    this.pathSegment,
    Object? pathKey,
    this.operation = SchemaOperation.parse,
  }) : pathKey = pathKey ?? pathSegment;

  /// Escapes a JSON Pointer segment per RFC 6901.
  static String _escapeJsonPointerSegment(String segment) {
    return segment.replaceAll('~', '~0').replaceAll('/', '~1');
  }

  /// The full JSON Pointer path (RFC 6901) from root to this context.
  String get path {
    if (parent == null) {
      return '#';
    }

    final parentPath = parent!.path;

    if (pathSegment == '') {
      return parentPath;
    }

    final segment = pathSegment ?? name;
    final escapedSegment = _escapeJsonPointerSegment(segment);

    return parentPath == '#'
        ? '#/$escapedSegment'
        : '$parentPath/$escapedSegment';
  }

  /// Creates a child context for nested validation.
  ///
  /// The child inherits the parent's [operation] unless overridden.
  SchemaContext createChild({
    required String name,
    required AnyAckSchema schema,
    required Object? value,
    String? pathSegment,
    Object? pathKey,
    SchemaOperation? operation,
  }) {
    return SchemaContext(
      name: name,
      schema: schema,
      value: value,
      parent: this,
      pathSegment: pathSegment,
      pathKey: pathKey,
      operation: operation ?? this.operation,
    );
  }

  @override
  String toString() {
    final schemaTypeString = schema.schemaTypeName;
    final valueString = value?.toString() ?? 'null';

    return 'SchemaContext(name: "$name", path: "$path", schema: $schemaTypeString, value: "$valueString", operation: ${operation.name})';
  }
}
