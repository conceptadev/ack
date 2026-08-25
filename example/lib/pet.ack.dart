// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'pet.dart';

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

  String get type;
  Map<String, dynamic> toJson() => Map<String, dynamic>.from($ack.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() => $ack.safeEncode(this);

  static Pet _fromAckRuntime(Map<String, Object?> value) {
    return switch (value['type']) {
      'cat' => Cat._fromAckRuntime(value),
      'dog' => Dog._fromAckRuntime(value),
      final unknown => throw StateError('Unknown type: $unknown'),
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
  String get type => 'cat';

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
    'type': 'cat',
    ..._$CatToJson(this),
  };

  static int _ackFromRuntimeLives(Object? value) => value as int;

  static Object? _ackToRuntimeLives(int value) => value;
}

/// Discriminated model branch generated from `dogSchema`.
@AckType.jsonSerializable
final class Dog extends Pet {
  Dog({required this.breed});

  factory Dog.parse(Object? input) {
    return $ack.parse(input);
  }

  factory Dog.fromJson(Map<String, dynamic> json) {
    return $ack.parse(json);
  }

  final String breed;

  static final $ack = AckModelAdapter(
    schema: () => petSchema.effectiveBranch('dog'),
    fromRuntime: Dog._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<Dog> safeParse(Object? input) => $ack.safeParse(input);

  @override
  String get type => 'dog';

  Dog copyWith({String? breed}) => Dog(breed: breed ?? this.breed);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Dog &&
          runtimeType == other.runtimeType &&
          deepEquals(breed, other.breed));

  @override
  int get hashCode => Object.hashAll([runtimeType, deepHashCode(breed)]);

  @override
  String toString() => 'Dog(breed: $breed)';

  static Dog _fromAckRuntime(Map<String, Object?> value) =>
      _$DogFromJson(Map<String, dynamic>.from(value));

  @override
  Map<String, Object?> _toAckRuntime() => <String, Object?>{
    'type': 'dog',
    ..._$DogToJson(this),
  };

  static String _ackFromRuntimeBreed(Object? value) => value as String;

  static Object? _ackToRuntimeBreed(String value) => value;
}
