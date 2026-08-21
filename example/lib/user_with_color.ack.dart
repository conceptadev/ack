// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'user_with_color.dart';

// **************************************************************************
// AckSchemaGenerator
// **************************************************************************

/// Immutable value model generated from `colorSchema`.
@AckType.jsonSerializable
final class ColorModel {
  ColorModel(this.value);

  factory ColorModel.parse(Object? input) {
    return $ack.parse(input);
  }

  factory ColorModel.fromJson(String json) {
    return $ack.parse(json);
  }

  final Color value;

  static final $ack = AckModelAdapter(
    schema: () => colorSchema,
    fromRuntime: ColorModel._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<ColorModel> safeParse(Object? input) =>
      $ack.safeParse(input);

  String toJson() => $ack.encode(this);

  SchemaResult<String> safeToJson() => $ack.safeEncode(this);

  static ColorModel _fromAckRuntime(Color value) =>
      _$ColorModelFromJson(<String, dynamic>{'value': value});

  Color _toAckRuntime() => _$ColorModelToJson(this)['value'] as Color;

  static Color _ackFromRuntimeValue(Object? value) => value as Color;

  static Object? _ackToRuntimeValue(Color value) => value;
}

/// Immutable model generated from `profileSchema`.
@AckType.jsonSerializable
final class Profile {
  Profile({required this.bio, this.website});

  factory Profile.parse(Object? input) {
    return $ack.parse(input);
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return $ack.parse(json);
  }

  final String bio;

  final Uri? website;

  static final $ack = AckModelAdapter(
    schema: () => profileSchema,
    fromRuntime: Profile._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<Profile> safeParse(Object? input) =>
      $ack.safeParse(input);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from($ack.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() => $ack.safeEncode(this);

  static Profile _fromAckRuntime(Map<String, Object?> value) =>
      _$ProfileFromJson(Map<String, dynamic>.from(value));

  Map<String, Object?> _toAckRuntime() => <String, Object?>{
    ..._$ProfileToJson(this),
  };

  static String _ackFromRuntimeBio(Object? value) => value as String;

  static Object? _ackToRuntimeBio(String value) => value;

  static Uri? _ackFromRuntimeWebsite(Object? value) => value as Uri?;

  static Object? _ackToRuntimeWebsite(Uri? value) => value;
}

/// Immutable model generated from `userWithColorSchema`.
@AckType.jsonSerializable
final class UserWithColor {
  UserWithColor({
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.profile,
    required this.color,
    this.favoriteColor,
    required this.pet,
    required List<Pet> pets,
  }) : pets = List<Pet>.unmodifiable(pets.map((item) => item));

  factory UserWithColor.parse(Object? input) {
    return $ack.parse(input);
  }

  factory UserWithColor.fromJson(Map<String, dynamic> json) {
    return $ack.parse(json);
  }

  final String firstName;

  final String lastName;

  final int age;

  final Profile profile;

  final ColorModel color;

  final ColorModel? favoriteColor;

  final Pet pet;

  final List<Pet> pets;

  static final $ack = AckModelAdapter(
    schema: () => userWithColorSchema,
    fromRuntime: UserWithColor._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<UserWithColor> safeParse(Object? input) =>
      $ack.safeParse(input);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from($ack.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() => $ack.safeEncode(this);

  static UserWithColor _fromAckRuntime(Map<String, Object?> value) =>
      _$UserWithColorFromJson(Map<String, dynamic>.from(value));

  Map<String, Object?> _toAckRuntime() => <String, Object?>{
    ..._$UserWithColorToJson(this),
  };

  static String _ackFromRuntimeFirstName(Object? value) => value as String;

  static Object? _ackToRuntimeFirstName(String value) => value;

  static String _ackFromRuntimeLastName(Object? value) => value as String;

  static Object? _ackToRuntimeLastName(String value) => value;

  static int _ackFromRuntimeAge(Object? value) => value as int;

  static Object? _ackToRuntimeAge(int value) => value;

  static Profile _ackFromRuntimeProfile(Object? value) =>
      Profile.$ack.fromRuntime(value as Map<String, Object?>);

  static Object? _ackToRuntimeProfile(Profile value) =>
      Profile.$ack.toRuntime(value);

  static ColorModel _ackFromRuntimeColor(Object? value) =>
      ColorModel.$ack.fromRuntime(value as Color);

  static Object? _ackToRuntimeColor(ColorModel value) =>
      ColorModel.$ack.toRuntime(value);

  static ColorModel? _ackFromRuntimeFavoriteColor(Object? value) =>
      switch (value) {
        null => null,
        final fieldValue => ColorModel.$ack.fromRuntime(fieldValue as Color),
      };

  static Object? _ackToRuntimeFavoriteColor(ColorModel? value) =>
      switch (value) {
        null => null,
        final fieldValue => ColorModel.$ack.toRuntime(fieldValue),
      };

  static Pet _ackFromRuntimePet(Object? value) =>
      Pet.$ack.fromRuntime(value as Map<String, Object?>);

  static Object? _ackToRuntimePet(Pet value) => Pet.$ack.toRuntime(value);

  static List<Pet> _ackFromRuntimePets(Object? value) => (value as List)
      .map((item) => Pet.$ack.fromRuntime(item as Map<String, Object?>))
      .toList();

  static Object? _ackToRuntimePets(List<Pet> value) =>
      value.map((item) => Pet.$ack.toRuntime(item)).toList(growable: false);
}
