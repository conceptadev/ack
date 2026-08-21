// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'user_with_color.dart';

// **************************************************************************
// AckSchemaGenerator
// **************************************************************************

/// Immutable value model generated from `colorSchema`.
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

  static ColorModel _fromAckRuntime(Color value) => ColorModel(value);

  Color _toAckRuntime() => value;
}

/// Immutable model generated from `profileSchema`.
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

  static Profile _fromAckRuntime(Map<String, Object?> value) {
    return Profile(
      bio: value['bio'] as String,
      website: value['website'] as Uri?,
    );
  }

  Map<String, Object?> _toAckRuntime() {
    return <String, Object?>{
      'bio': bio,
      if (website != null) 'website': website!,
    };
  }
}

/// Immutable model generated from `userWithColorSchema`.
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

  static UserWithColor _fromAckRuntime(Map<String, Object?> value) {
    return UserWithColor(
      firstName: value['firstName'] as String,
      lastName: value['lastName'] as String,
      age: value['age'] as int,
      profile: Profile.$ack.fromRuntime(
        value['profile'] as Map<String, Object?>,
      ),
      color: ColorModel.$ack.fromRuntime(value['color'] as Color),
      favoriteColor: switch (value['favoriteColor']) {
        null => null,
        final fieldValue => ColorModel.$ack.fromRuntime(fieldValue as Color),
      },
      pet: Pet.$ack.fromRuntime(value['pet'] as Map<String, Object?>),
      pets: List<Pet>.unmodifiable(
        (value['pets'] as List).map(
          (item) => Pet.$ack.fromRuntime(item as Map<String, Object?>),
        ),
      ),
    );
  }

  Map<String, Object?> _toAckRuntime() {
    return <String, Object?>{
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'profile': Profile.$ack.toRuntime(profile),
      'color': ColorModel.$ack.toRuntime(color),
      if (favoriteColor != null)
        'favoriteColor': ColorModel.$ack.toRuntime(favoriteColor!),
      'pet': Pet.$ack.toRuntime(pet),
      'pets': pets
          .map((item) => Pet.$ack.toRuntime(item))
          .toList(growable: false),
    };
  }
}
