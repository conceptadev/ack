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

  static Cat _fromAckRuntime(Map<String, Object?> value) {
    return Cat(lives: value['lives'] as int);
  }

  @override
  Map<String, Object?> _toAckRuntime() {
    return <String, Object?>{'type': 'cat', 'lives': lives};
  }
}

/// Discriminated model branch generated from `dogSchema`.
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

  static Dog _fromAckRuntime(Map<String, Object?> value) {
    return Dog(breed: value['breed'] as String);
  }

  @override
  Map<String, Object?> _toAckRuntime() {
    return <String, Object?>{'type': 'dog', 'breed': breed};
  }
}
