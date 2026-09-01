// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'schema_types_discriminated.dart';

// **************************************************************************
// AckModelGenerator
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
@AckInfer.jsonSerializable
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

  Cat copyWith({int? lives}) => Cat(lives: lives ?? this.lives);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cat &&
          runtimeType == other.runtimeType &&
          deepEquals(lives, other.lives));

  @override
  int get hashCode => Object.hashAll([runtimeType, deepHashCode(lives)]);

  @override
  String toString() => 'Cat(lives: $lives)';

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
@AckInfer.jsonSerializable
final class Dog extends Pet {
  Dog({
    required this.bark,
    Map<String, Object?> additionalProperties = const {},
  }) : additionalProperties = deepUnmodifiableJsonMap(additionalProperties);

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

  Dog copyWith({bool? bark, Map<String, Object?>? additionalProperties}) => Dog(
    bark: bark ?? this.bark,
    additionalProperties: additionalProperties ?? this.additionalProperties,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Dog &&
          runtimeType == other.runtimeType &&
          deepEquals(bark, other.bark) &&
          deepEquals(additionalProperties, other.additionalProperties));

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    deepHashCode(bark),
    deepHashCode(additionalProperties),
  ]);

  @override
  String toString() =>
      'Dog(bark: $bark, additionalProperties: $additionalProperties)';

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
    const declared = <String>{'kind', 'bark'};
    final result = <String, Object?>{..._$DogToJson(this)};
    result.remove('additionalProperties');
    return <String, Object?>{
      for (final entry in additionalProperties.entries)
        if (!declared.contains(entry.key)) entry.key: entry.value,
      'kind': 'dog',
      ...result,
    };
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
