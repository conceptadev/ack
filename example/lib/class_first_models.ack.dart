// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'class_first_models.dart';

// **************************************************************************
// AckSchemaGenerator
// **************************************************************************

final _catObject = Ack.object({
  'id': Ack.string(),
  'lives': Ack.integer().min(1).max(9),
});

final catSchema = _catObject.codec<Cat>(
  decode: _$CatFromRuntime,
  encode: _$CatToRuntime,
);

Cat _$CatFromRuntime(Map<String, Object?> value) =>
    _$CatFromJson(Map<String, dynamic>.from(value));

Map<String, Object?> _$CatToRuntime(Cat model) {
  final result = <String, Object?>{..._$CatToJson(model)};
  return <String, Object?>{...result, 'type': 'cat'};
}

extension CatAck on Cat {
  Map<String, dynamic> toJson() =>
      Map<String, dynamic>.from(catSchema.encode(this)!);

  SchemaResult<Map<String, Object?>> safeToJson() => catSchema.safeEncode(this);
}

String _ackCatFromRuntimeId(Object? value) => value as String;
Object? _ackCatToRuntimeId(String value) => value;
int _ackCatFromRuntimeLives(Object? value) => value as int;
Object? _ackCatToRuntimeLives(int value) => value;

final _dogObject = Ack.object({'id': Ack.string(), 'breed': Ack.string()});

final dogSchema = _dogObject.codec<Dog>(
  decode: _$DogFromRuntime,
  encode: _$DogToRuntime,
);

Dog _$DogFromRuntime(Map<String, Object?> value) =>
    _$DogFromJson(Map<String, dynamic>.from(value));

Map<String, Object?> _$DogToRuntime(Dog model) {
  final result = <String, Object?>{..._$DogToJson(model)};
  return <String, Object?>{...result, 'type': 'Dog'};
}

extension DogAck on Dog {
  Map<String, dynamic> toJson() =>
      Map<String, dynamic>.from(dogSchema.encode(this)!);

  SchemaResult<Map<String, Object?>> safeToJson() => dogSchema.safeEncode(this);
}

String _ackDogFromRuntimeId(Object? value) => value as String;
Object? _ackDogToRuntimeId(String value) => value;
String _ackDogFromRuntimeBreed(Object? value) => value as String;
Object? _ackDogToRuntimeBreed(String value) => value;

final petSchema =
    Ack.discriminated(
      discriminatorKey: 'type',
      schemas: {'cat': _catObject, 'Dog': _dogObject},
    ).codec<Pet>(
      decode: (value) => switch (value['type']) {
        'cat' => _$CatFromRuntime(value),
        'Dog' => _$DogFromRuntime(value),
        final unknown => throw StateError('Unknown type: $unknown'),
      },
      encode: (model) => switch (model) {
        Cat() => _$CatToRuntime(model),
        Dog() => _$DogToRuntime(model),
      },
    );

extension PetAck on Pet {
  Map<String, dynamic> toJson() =>
      Map<String, dynamic>.from(petSchema.encode(this)!);

  SchemaResult<Map<String, Object?>> safeToJson() => petSchema.safeEncode(this);
}

final accountSchema = Ack.object({
  'display_name': Ack.string().minLength(2),
  'website': Ack.uri().optional(),
  'role': Ack.string().withDefault('member'),
}).codec<Account>(decode: _$AccountFromRuntime, encode: _$AccountToRuntime);

Account _$AccountFromRuntime(Map<String, Object?> value) =>
    _$AccountFromJson(Map<String, dynamic>.from(value));

Map<String, Object?> _$AccountToRuntime(Account model) => <String, Object?>{
  ..._$AccountToJson(model),
};

extension AccountAck on Account {
  Map<String, dynamic> toJson() =>
      Map<String, dynamic>.from(accountSchema.encode(this)!);

  SchemaResult<Map<String, Object?>> safeToJson() =>
      accountSchema.safeEncode(this);
}

String _ackAccountFromRuntimeDisplayName(Object? value) => value as String;
Object? _ackAccountToRuntimeDisplayName(String value) => value;
Uri? _ackAccountFromRuntimeWebsite(Object? value) => value as Uri?;
Object? _ackAccountToRuntimeWebsite(Uri? value) => value;
String? _ackAccountFromRuntimeRole(Object? value) => value as String;
Object? _ackAccountToRuntimeRole(String value) => value;
