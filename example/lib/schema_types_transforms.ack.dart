// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'schema_types_transforms.dart';

// **************************************************************************
// AckModelGenerator
// **************************************************************************

/// Immutable value model generated from `colorSchema`.
@AckInfer.jsonSerializable
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

  ColorModel copyWith({Color? value}) => ColorModel(value ?? this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ColorModel &&
          runtimeType == other.runtimeType &&
          deepEquals(value, other.value));

  @override
  int get hashCode => Object.hashAll([runtimeType, deepHashCode(value)]);

  @override
  String toString() => 'ColorModel(value: $value)';

  static ColorModel _fromAckRuntime(Color value) =>
      _$ColorModelFromJson(<String, dynamic>{'value': value});

  Color _toAckRuntime() => _$ColorModelToJson(this)['value'] as Color;

  static Color _ackFromRuntimeValue(Object? value) => value as Color;

  static Object? _ackToRuntimeValue(Color value) => value;
}

/// Immutable model generated from `profileSchema`.
@AckInfer.jsonSerializable
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

  Profile copyWith({
    Uri? homepage,
    DateTime? birthday,
    DateTime? lastLogin,
    Duration? timeout,
    List<Uri>? links,
    Color? favoriteColor,
    String? slug,
    ColorModel? accent,
    List<ColorModel>? colors,
    List<Color>? customColors,
    TagList? tagList,
  }) => Profile(
    homepage: homepage ?? this.homepage,
    birthday: birthday ?? this.birthday,
    lastLogin: lastLogin ?? this.lastLogin,
    timeout: timeout ?? this.timeout,
    links: links ?? this.links,
    favoriteColor: favoriteColor ?? this.favoriteColor,
    slug: slug ?? this.slug,
    accent: accent ?? this.accent,
    colors: colors ?? this.colors,
    customColors: customColors ?? this.customColors,
    tagList: tagList ?? this.tagList,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          runtimeType == other.runtimeType &&
          deepEquals(homepage, other.homepage) &&
          deepEquals(birthday, other.birthday) &&
          deepEquals(lastLogin, other.lastLogin) &&
          deepEquals(timeout, other.timeout) &&
          deepEquals(links, other.links) &&
          deepEquals(favoriteColor, other.favoriteColor) &&
          deepEquals(slug, other.slug) &&
          deepEquals(accent, other.accent) &&
          deepEquals(colors, other.colors) &&
          deepEquals(customColors, other.customColors) &&
          deepEquals(tagList, other.tagList));

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    deepHashCode(homepage),
    deepHashCode(birthday),
    deepHashCode(lastLogin),
    deepHashCode(timeout),
    deepHashCode(links),
    deepHashCode(favoriteColor),
    deepHashCode(slug),
    deepHashCode(accent),
    deepHashCode(colors),
    deepHashCode(customColors),
    deepHashCode(tagList),
  ]);

  @override
  String toString() =>
      'Profile(homepage: $homepage, birthday: $birthday, lastLogin: $lastLogin, timeout: $timeout, links: $links, favoriteColor: $favoriteColor, slug: $slug, accent: $accent, colors: $colors, customColors: $customColors, tagList: $tagList)';

  static Profile _fromAckRuntime(Map<String, Object?> value) =>
      _$ProfileFromJson(Map<String, dynamic>.from(value));

  Map<String, Object?> _toAckRuntime() => <String, Object?>{
    ..._$ProfileToJson(this),
  };

  static Uri _ackFromRuntimeHomepage(Object? value) => value as Uri;

  static Object? _ackToRuntimeHomepage(Uri value) => value;

  static DateTime _ackFromRuntimeBirthday(Object? value) => value as DateTime;

  static Object? _ackToRuntimeBirthday(DateTime value) => value;

  static DateTime _ackFromRuntimeLastLogin(Object? value) => value as DateTime;

  static Object? _ackToRuntimeLastLogin(DateTime value) => value;

  static Duration _ackFromRuntimeTimeout(Object? value) => value as Duration;

  static Object? _ackToRuntimeTimeout(Duration value) => value;

  static List<Uri> _ackFromRuntimeLinks(Object? value) =>
      (value as List).map((item) => item as Uri).toList();

  static Object? _ackToRuntimeLinks(List<Uri> value) =>
      value.map((item) => item).toList(growable: false);

  static Color _ackFromRuntimeFavoriteColor(Object? value) => value as Color;

  static Object? _ackToRuntimeFavoriteColor(Color value) => value;

  static String _ackFromRuntimeSlug(Object? value) => value as String;

  static Object? _ackToRuntimeSlug(String value) => value;

  static ColorModel _ackFromRuntimeAccent(Object? value) =>
      ColorModel.$ack.fromRuntime(value as Color);

  static Object? _ackToRuntimeAccent(ColorModel value) =>
      ColorModel.$ack.toRuntime(value);

  static List<ColorModel> _ackFromRuntimeColors(Object? value) =>
      (value as List)
          .map((item) => ColorModel.$ack.fromRuntime(item as Color))
          .toList();

  static Object? _ackToRuntimeColors(List<ColorModel> value) => value
      .map((item) => ColorModel.$ack.toRuntime(item))
      .toList(growable: false);

  static List<Color> _ackFromRuntimeCustomColors(Object? value) =>
      (value as List).map((item) => item as Color).toList();

  static Object? _ackToRuntimeCustomColors(List<Color> value) =>
      value.map((item) => item).toList(growable: false);

  static TagList _ackFromRuntimeTagList(Object? value) => value as TagList;

  static Object? _ackToRuntimeTagList(TagList value) => value;
}
