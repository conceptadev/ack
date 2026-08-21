// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'schema_types_discriminated.dart';

// **************************************************************************
// AckSchemaGenerator
// **************************************************************************

/// Discriminated model base generated from `petSchema`.
sealed class Pet {
  const Pet();

  factory Pet.parse(Object? input) {
    return $ack.parse(input);
  }

  factory Pet.fromJson(Map<String, dynamic> json) {
    return $ack.parse(json);
  }

  static final $ack = AckModelAdapter(
    schema: () => petSchema,
    fromRuntime: Pet._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<Pet> safeParse(Object? input) => $ack.safeParse(input);

  String get kind;
  Map<String, dynamic> toJson() => Map<String, dynamic>.from($ack.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() => $ack.safeEncode(this);

  static Pet _fromAckRuntime(Map<String, Object?> value) {
    return switch (value['kind']) {
      'cat' => Cat._fromAckRuntime(value),
      'dog' => Dog._fromAckRuntime(value),
      final unknown => throw StateError('Unknown kind: $unknown'),
    };
  }

  Map<String, Object?> _toAckRuntime();
}

/// Discriminated model branch generated from `catSchema`.
@AckType.jsonSerializable
final class Cat extends Pet {
  Cat({required this.lives});

  factory Cat.parse(Object? input) {
    return $ack.parse(input);
  }

  factory Cat.fromJson(Map<String, dynamic> json) {
    return $ack.parse(json);
  }

  final int lives;

  static final $ack = AckModelAdapter(
    schema: () => petSchema.effectiveBranch('cat'),
    fromRuntime: Cat._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<Cat> safeParse(Object? input) => $ack.safeParse(input);

  @override
  String get kind => 'cat';

  static Cat _fromAckRuntime(Map<String, Object?> value) =>
      _$CatFromJson(Map<String, dynamic>.from(value));

  @override
  Map<String, Object?> _toAckRuntime() => <String, Object?>{
    'kind': 'cat',
    ..._$CatToJson(this),
  };

  static int _ackFromRuntimeLives(Object? value) => value as int;

  static Object? _ackToRuntimeLives(int value) => value;
}

/// Discriminated model branch generated from `dogSchema`.
@AckType.jsonSerializable
final class Dog extends Pet {
  Dog({
    required this.bark,
    Map<String, Object?> additionalProperties = const {},
  }) : additionalProperties = _ackImmutableCopyMap(additionalProperties);

  factory Dog.parse(Object? input) {
    return $ack.parse(input);
  }

  factory Dog.fromJson(Map<String, dynamic> json) {
    return $ack.parse(json);
  }

  final bool bark;

  /// Properties accepted by a schema with additional properties.
  final Map<String, Object?> additionalProperties;

  static final $ack = AckModelAdapter(
    schema: () => petSchema.effectiveBranch('dog'),
    fromRuntime: Dog._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<Dog> safeParse(Object? input) => $ack.safeParse(input);

  @override
  String get kind => 'dog';

  static Dog _fromAckRuntime(Map<String, Object?> value) {
    const declared = <String>{'kind', 'bark'};
    return _$DogFromJson(<String, dynamic>{
      ...value,
      'additionalProperties': Map<String, Object?>.fromEntries(
        value.entries.where((entry) => !declared.contains(entry.key)),
      ),
    });
  }

  @override
  Map<String, Object?> _toAckRuntime() {
    final result = <String, Object?>{..._$DogToJson(this)};
    result.remove('additionalProperties');
    return <String, Object?>{...additionalProperties, 'kind': 'dog', ...result};
  }

  static bool _ackFromRuntimeBark(Object? value) => value as bool;

  static Object? _ackToRuntimeBark(bool value) => value;

  static Map<String, Object?>? _ackFromRuntimeAdditionalProperties(
    Object? value,
  ) => value as Map<String, Object?>?;

  static Object? _ackToRuntimeAdditionalProperties(
    Map<String, Object?> value,
  ) => value;
}

Object? _ackImmutableCopyValue(Object? value) => switch (value) {
  List() => List.unmodifiable(value.map(_ackImmutableCopyValue)),
  Set() => Set.unmodifiable(value.map(_ackImmutableCopyValue)),
  Map() => Map.unmodifiable(
    value.map((key, item) => MapEntry(key, _ackImmutableCopyValue(item))),
  ),
  _ => value,
};
Map<String, Object?> _ackImmutableCopyMap(Map<String, Object?> value) =>
    Map.unmodifiable(
      value.map((key, item) => MapEntry(key, _ackImmutableCopyValue(item))),
    );
