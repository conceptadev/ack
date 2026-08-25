// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'class_first_models.dart';

// **************************************************************************
// AckSchemaGenerator
// **************************************************************************

final _catObject = Ack.object({
  'type': Ack.literal('cat'),
  'id': Ack.string(),
  'lives': Ack.integer().min(1).max(9),
});

final _catSchema = _catObject.codec<Cat>(
  decode: _$CatFromRuntime,
  encode: _$CatToRuntime,
);

abstract final class CatSchema {
  static AckSchema<Map<String, Object?>, Cat> get schema => _catSchema;

  static Cat parse(Object? value, {String? debugName}) =>
      _catSchema.parse(value, debugName: debugName)!;

  static SchemaResult<Cat> safeParse(Object? value, {String? debugName}) =>
      _catSchema.safeParse(value, debugName: debugName);

  static Cat fromJson(Map<String, dynamic> json) => parse(json);

  static Map<String, Object?> encode(Cat value, {String? debugName}) =>
      _catSchema.encode(value, debugName: debugName)!;

  static SchemaResult<Map<String, Object?>> safeEncode(
    Cat value, {
    String? debugName,
  }) => _catSchema.safeEncode(value, debugName: debugName);

  static Map<String, Object?> toJsonSchema() => _catSchema.toJsonSchema();

  static AckSchemaModel toSchemaModel() =>
      AckSchemaModelExtension(_catSchema).toSchemaModel();
}

Cat _$CatFromRuntime(Map<String, Object?> value) =>
    _$CatFromJson(Map<String, dynamic>.from(value));

Map<String, Object?> _$CatToRuntime(Cat model) {
  final result = <String, Object?>{..._$CatToJson(model)};
  return <String, Object?>{...result, 'type': 'cat'};
}

extension CatAck on Cat {
  Map<String, dynamic> toJson() =>
      Map<String, dynamic>.from(CatSchema.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() => CatSchema.safeEncode(this);
}

String _ackCatFromRuntimeId(Object? value) => value as String;
Object? _ackCatToRuntimeId(String value) => value;
int _ackCatFromRuntimeLives(Object? value) => value as int;
Object? _ackCatToRuntimeLives(int value) => value;

final _dogObject = Ack.object({
  'type': Ack.literal('Dog'),
  'id': Ack.string(),
  'breed': Ack.string(),
});

final _dogSchema = _dogObject.codec<Dog>(
  decode: _$DogFromRuntime,
  encode: _$DogToRuntime,
);

abstract final class DogSchema {
  static AckSchema<Map<String, Object?>, Dog> get schema => _dogSchema;

  static Dog parse(Object? value, {String? debugName}) =>
      _dogSchema.parse(value, debugName: debugName)!;

  static SchemaResult<Dog> safeParse(Object? value, {String? debugName}) =>
      _dogSchema.safeParse(value, debugName: debugName);

  static Dog fromJson(Map<String, dynamic> json) => parse(json);

  static Map<String, Object?> encode(Dog value, {String? debugName}) =>
      _dogSchema.encode(value, debugName: debugName)!;

  static SchemaResult<Map<String, Object?>> safeEncode(
    Dog value, {
    String? debugName,
  }) => _dogSchema.safeEncode(value, debugName: debugName);

  static Map<String, Object?> toJsonSchema() => _dogSchema.toJsonSchema();

  static AckSchemaModel toSchemaModel() =>
      AckSchemaModelExtension(_dogSchema).toSchemaModel();
}

Dog _$DogFromRuntime(Map<String, Object?> value) =>
    _$DogFromJson(Map<String, dynamic>.from(value));

Map<String, Object?> _$DogToRuntime(Dog model) {
  final result = <String, Object?>{..._$DogToJson(model)};
  return <String, Object?>{...result, 'type': 'Dog'};
}

extension DogAck on Dog {
  Map<String, dynamic> toJson() =>
      Map<String, dynamic>.from(DogSchema.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() => DogSchema.safeEncode(this);
}

String _ackDogFromRuntimeId(Object? value) => value as String;
Object? _ackDogToRuntimeId(String value) => value;
String _ackDogFromRuntimeBreed(Object? value) => value as String;
Object? _ackDogToRuntimeBreed(String value) => value;

final _petSchema =
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

abstract final class PetSchema {
  static AckSchema<Map<String, Object?>, Pet> get schema => _petSchema;

  static Pet parse(Object? value, {String? debugName}) =>
      _petSchema.parse(value, debugName: debugName)!;

  static SchemaResult<Pet> safeParse(Object? value, {String? debugName}) =>
      _petSchema.safeParse(value, debugName: debugName);

  static Pet fromJson(Map<String, dynamic> json) => parse(json);

  static Map<String, Object?> encode(Pet value, {String? debugName}) =>
      _petSchema.encode(value, debugName: debugName)!;

  static SchemaResult<Map<String, Object?>> safeEncode(
    Pet value, {
    String? debugName,
  }) => _petSchema.safeEncode(value, debugName: debugName);

  static Map<String, Object?> toJsonSchema() => _petSchema.toJsonSchema();

  static AckSchemaModel toSchemaModel() =>
      AckSchemaModelExtension(_petSchema).toSchemaModel();
}

extension PetAck on Pet {
  Map<String, dynamic> toJson() =>
      Map<String, dynamic>.from(PetSchema.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() => PetSchema.safeEncode(this);
}

final _accountSchema = Ack.object({
  'display_name': Ack.string().minLength(2),
  'website': Ack.uri().optional(),
  'role': Ack.string().withDefault('member'),
}).codec<Account>(decode: _$AccountFromRuntime, encode: _$AccountToRuntime);

abstract final class AccountSchema {
  static AckSchema<Map<String, Object?>, Account> get schema => _accountSchema;

  static Account parse(Object? value, {String? debugName}) =>
      _accountSchema.parse(value, debugName: debugName)!;

  static SchemaResult<Account> safeParse(Object? value, {String? debugName}) =>
      _accountSchema.safeParse(value, debugName: debugName);

  static Account fromJson(Map<String, dynamic> json) => parse(json);

  static Map<String, Object?> encode(Account value, {String? debugName}) =>
      _accountSchema.encode(value, debugName: debugName)!;

  static SchemaResult<Map<String, Object?>> safeEncode(
    Account value, {
    String? debugName,
  }) => _accountSchema.safeEncode(value, debugName: debugName);

  static Map<String, Object?> toJsonSchema() => _accountSchema.toJsonSchema();

  static AckSchemaModel toSchemaModel() =>
      AckSchemaModelExtension(_accountSchema).toSchemaModel();
}

Account _$AccountFromRuntime(Map<String, Object?> value) =>
    _$AccountFromJson(Map<String, dynamic>.from(value));

Map<String, Object?> _$AccountToRuntime(Account model) => <String, Object?>{
  ..._$AccountToJson(model),
};

extension AccountAck on Account {
  Map<String, dynamic> toJson() =>
      Map<String, dynamic>.from(AccountSchema.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() =>
      AccountSchema.safeEncode(this);
}

String _ackAccountFromRuntimeDisplayName(Object? value) => value as String;
Object? _ackAccountToRuntimeDisplayName(String value) => value;
Uri? _ackAccountFromRuntimeWebsite(Object? value) => value as Uri?;
Object? _ackAccountToRuntimeWebsite(Uri? value) => value;
String? _ackAccountFromRuntimeRole(Object? value) => value as String;
Object? _ackAccountToRuntimeRole(String value) => value;
