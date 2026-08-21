// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema_types_discriminated.dart';

// **************************************************************************
// AckJsonSerializableGenerator
// **************************************************************************

Cat _$CatFromJson(Map<String, dynamic> json) =>
    Cat(lives: Cat._ackFromRuntimeLives(json['lives']));

Map<String, dynamic> _$CatToJson(Cat instance) => <String, dynamic>{
  'lives': Cat._ackToRuntimeLives(instance.lives),
};

Dog _$DogFromJson(Map<String, dynamic> json) => Dog(
  bark: Dog._ackFromRuntimeBark(json['bark']),
  additionalProperties:
      Dog._ackFromRuntimeAdditionalProperties(json['additionalProperties']) ??
      const {},
);

Map<String, dynamic> _$DogToJson(Dog instance) => <String, dynamic>{
  'bark': Dog._ackToRuntimeBark(instance.bark),
  'additionalProperties': Dog._ackToRuntimeAdditionalProperties(
    instance.additionalProperties,
  ),
};
