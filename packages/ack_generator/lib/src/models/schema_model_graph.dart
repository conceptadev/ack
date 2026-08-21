/// Stable identity for a schema declaration across libraries.
final class AckSchemaId {
  const AckSchemaId({
    required this.libraryUri,
    required this.declarationName,
  });

  final Uri libraryUri;
  final String declarationName;

  @override
  bool operator ==(Object other) {
    return other is AckSchemaId &&
        other.libraryUri == libraryUri &&
        other.declarationName == declarationName;
  }

  @override
  int get hashCode => Object.hash(libraryUri, declarationName);

  @override
  String toString() => '$libraryUri::$declarationName';
}

/// Whether every value in a generated model graph can be encoded back to the
/// schema boundary.
enum AckEncodeCapability {
  bidirectional,
  parseOnly,
}

/// Input-presence semantics for an object field.
///
/// Presence and nullability are deliberately separate. A field can be required
/// and nullable, optional and non-nullable, or defaulted by the schema.
enum AckFieldPresence {
  required,
  optional,
  defaulted,
}

/// A normalized Dart/runtime type used by generation.
///
/// Analyzer objects and output-specific cast strings must not escape the
/// analysis layer. Emitters consume this structural representation instead.
sealed class AckTypeRef {
  const AckTypeRef();

  Iterable<AckSchemaId> get modelDependencies => const [];
}

/// A core scalar such as `String`, `int`, `double`, `bool`, or `num`.
final class AckScalarTypeRef extends AckTypeRef {
  const AckScalarTypeRef(this.dartType);

  final String dartType;
}

/// A visible type declared outside the generated model graph.
final class AckExternalTypeRef extends AckTypeRef {
  const AckExternalTypeRef({
    required this.dartType,
    required this.libraryUri,
    this.importPrefix,
  });

  final String dartType;
  final Uri libraryUri;
  final String? importPrefix;

  String get visibleName {
    final prefix = importPrefix;
    return prefix == null || prefix.isEmpty ? dartType : '$prefix.$dartType';
  }
}

/// A reference to another generated Ack model.
final class AckModelTypeRef extends AckTypeRef {
  const AckModelTypeRef({
    required this.schemaId,
    required this.className,
    this.importPrefix,
  });

  final AckSchemaId schemaId;
  final String className;
  final String? importPrefix;

  String get visibleName {
    final prefix = importPrefix;
    return prefix == null || prefix.isEmpty ? className : '$prefix.$className';
  }

  @override
  Iterable<AckSchemaId> get modelDependencies => [schemaId];
}

final class AckListTypeRef extends AckTypeRef {
  const AckListTypeRef(this.elementType);

  final AckTypeRef elementType;

  @override
  Iterable<AckSchemaId> get modelDependencies =>
      elementType.modelDependencies;
}

final class AckSetTypeRef extends AckTypeRef {
  const AckSetTypeRef(this.elementType);

  final AckTypeRef elementType;

  @override
  Iterable<AckSchemaId> get modelDependencies =>
      elementType.modelDependencies;
}

final class AckMapTypeRef extends AckTypeRef {
  const AckMapTypeRef(this.valueType);

  final AckTypeRef valueType;

  @override
  Iterable<AckSchemaId> get modelDependencies => valueType.modelDependencies;
}

/// A field in a normalized object model.
final class AckFieldNode {
  const AckFieldNode({
    required this.dartName,
    required this.jsonKey,
    required this.presence,
    required this.nullable,
    required this.runtimeType,
    this.description,
  });

  final String dartName;
  final String jsonKey;
  final AckFieldPresence presence;
  final bool nullable;
  final AckTypeRef runtimeType;
  final String? description;

  bool get isRequired => presence == AckFieldPresence.required;
}

/// Base node for a generated class or value object.
sealed class AckModelNode {
  const AckModelNode({
    required this.id,
    required this.className,
    required this.boundaryType,
    required this.runtimeType,
    required this.encodeCapability,
    this.description,
  });

  final AckSchemaId id;
  final String className;
  final AckTypeRef boundaryType;
  final AckTypeRef runtimeType;
  final AckEncodeCapability encodeCapability;
  final String? description;

  Iterable<AckSchemaId> get dependencies;
}

/// A regular immutable class generated from `Ack.object(...)`.
final class AckObjectModelNode extends AckModelNode {
  AckObjectModelNode({
    required super.id,
    required super.className,
    required super.boundaryType,
    required super.runtimeType,
    required super.encodeCapability,
    required Iterable<AckFieldNode> fields,
    this.additionalProperties = false,
    super.description,
  }) : fields = List.unmodifiable(fields);

  final List<AckFieldNode> fields;
  final bool additionalProperties;

  @override
  Iterable<AckSchemaId> get dependencies sync* {
    for (final field in fields) {
      yield* field.runtimeType.modelDependencies;
    }
  }
}

/// A value class generated from primitive, codec, list, or map root schemas.
final class AckValueModelNode extends AckModelNode {
  const AckValueModelNode({
    required super.id,
    required super.className,
    required super.boundaryType,
    required super.runtimeType,
    required super.encodeCapability,
    super.description,
  });

  @override
  Iterable<AckSchemaId> get dependencies => runtimeType.modelDependencies;
}

/// A sealed class generated from `Ack.discriminated(...)`.
final class AckUnionModelNode extends AckModelNode {
  AckUnionModelNode({
    required super.id,
    required super.className,
    required super.boundaryType,
    required super.runtimeType,
    required super.encodeCapability,
    required this.discriminatorKey,
    required Map<String, AckSchemaId> branches,
    super.description,
  }) : branches = Map.unmodifiable(branches);

  final String discriminatorKey;
  final Map<String, AckSchemaId> branches;

  @override
  Iterable<AckSchemaId> get dependencies => branches.values;
}

/// Resolution state used while building recursive model graphs.
enum AckResolutionState {
  unseen,
  visiting,
  resolved,
}

/// Mutable graph assembly with immutable model nodes.
///
/// A declaration is registered before its fields are analyzed. References to a
/// `visiting` declaration become graph edges instead of recursively expanding a
/// duplicate model. This supports self-recursive and mutually-recursive models.
final class AckModelGraph {
  final Map<AckSchemaId, AckModelNode> _nodes = {};
  final Map<AckSchemaId, AckResolutionState> _states = {};
  final List<AckSchemaId> _sourceOrder = [];

  Iterable<AckModelNode> get nodes sync* {
    for (final id in _sourceOrder) {
      final node = _nodes[id];
      if (node != null) yield node;
    }
  }

  AckResolutionState stateOf(AckSchemaId id) =>
      _states[id] ?? AckResolutionState.unseen;

  void begin(AckSchemaId id) {
    final state = stateOf(id);
    if (state == AckResolutionState.resolved) {
      throw StateError('Schema $id is already resolved.');
    }
    if (state == AckResolutionState.unseen) {
      _sourceOrder.add(id);
    }
    _states[id] = AckResolutionState.visiting;
  }

  void complete(AckModelNode node) {
    final state = stateOf(node.id);
    if (state != AckResolutionState.visiting) {
      throw StateError(
        'Schema ${node.id} must be visiting before it can be completed.',
      );
    }
    _nodes[node.id] = node;
    _states[node.id] = AckResolutionState.resolved;
  }

  AckModelNode? nodeFor(AckSchemaId id) => _nodes[id];

  /// Returns source-stable dependencies for diagnostics and tests.
  List<AckSchemaId> dependenciesOf(AckSchemaId id) {
    final node = _nodes[id];
    if (node == null) return const [];
    return List.unmodifiable(node.dependencies.toSet());
  }
}
