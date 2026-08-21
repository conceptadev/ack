// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'schema_types_transforms.dart';

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
  Profile({
    required this.homepage,
    required this.birthday,
    required this.lastLogin,
    required this.timeout,
    required List<Uri> links,
    required this.favoriteColor,
    required this.slug,
    required this.accent,
    required List<ColorModel> colors,
    required List<Color> customColors,
    required this.tagList,
  }) : links = List<Uri>.unmodifiable(links.map((item) => item)),
       colors = List<ColorModel>.unmodifiable(colors.map((item) => item)),
       customColors = List<Color>.unmodifiable(
         customColors.map((item) => item),
       );

  factory Profile.parse(Object? input) {
    return $ack.parse(input);
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return $ack.parse(json);
  }

  final Uri homepage;

  final DateTime birthday;

  final DateTime lastLogin;

  final Duration timeout;

  final List<Uri> links;

  final Color favoriteColor;

  final String slug;

  final ColorModel accent;

  final List<ColorModel> colors;

  final List<Color> customColors;

  final TagList tagList;

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
      homepage: value['homepage'] as Uri,
      birthday: value['birthday'] as DateTime,
      lastLogin: value['lastLogin'] as DateTime,
      timeout: value['timeout'] as Duration,
      links: List<Uri>.unmodifiable(
        (value['links'] as List).map((item) => item as Uri),
      ),
      favoriteColor: value['favoriteColor'] as Color,
      slug: value['slug'] as String,
      accent: ColorModel.$ack.fromRuntime(value['accent'] as Color),
      colors: List<ColorModel>.unmodifiable(
        (value['colors'] as List).map(
          (item) => ColorModel.$ack.fromRuntime(item as Color),
        ),
      ),
      customColors: List<Color>.unmodifiable(
        (value['customColors'] as List).map((item) => item as Color),
      ),
      tagList: value['tagList'] as TagList,
    );
  }

  Map<String, Object?> _toAckRuntime() {
    return <String, Object?>{
      'homepage': homepage,
      'birthday': birthday,
      'lastLogin': lastLogin,
      'timeout': timeout,
      'links': links.map((item) => item).toList(growable: false),
      'favoriteColor': favoriteColor,
      'slug': slug,
      'accent': ColorModel.$ack.toRuntime(accent),
      'colors': colors
          .map((item) => ColorModel.$ack.toRuntime(item))
          .toList(growable: false),
      'customColors': customColors.map((item) => item).toList(growable: false),
      'tagList': tagList,
    };
  }
}
