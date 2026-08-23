// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'schema_types_primitives.dart';

// **************************************************************************
// AckSchemaGenerator
// **************************************************************************

/// Immutable value model generated from `passwordSchema`.
@AckType.jsonSerializable
final class Password {
  Password(this.value);

  factory Password.parse(Object? input) {
    return $ack.parse(input);
  }

  factory Password.fromJson(String json) {
    return $ack.parse(json);
  }

  final String value;

  static final $ack = AckModelAdapter(
    schema: () => passwordSchema,
    fromRuntime: Password._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<Password> safeParse(Object? input) =>
      $ack.safeParse(input);

  String toJson() => $ack.encode(this);

  SchemaResult<String> safeToJson() => $ack.safeEncode(this);

  static Password _fromAckRuntime(String value) =>
      _$PasswordFromJson(<String, dynamic>{'value': value});

  String _toAckRuntime() => _$PasswordToJson(this)['value'] as String;

  static String _ackFromRuntimeValue(Object? value) => value as String;

  static Object? _ackToRuntimeValue(String value) => value;
}

/// Immutable value model generated from `ageSchema`.
@AckType.jsonSerializable
final class Age {
  Age(this.value);

  factory Age.parse(Object? input) {
    return $ack.parse(input);
  }

  factory Age.fromJson(int json) {
    return $ack.parse(json);
  }

  final int value;

  static final $ack = AckModelAdapter(
    schema: () => ageSchema,
    fromRuntime: Age._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<Age> safeParse(Object? input) => $ack.safeParse(input);

  int toJson() => $ack.encode(this);

  SchemaResult<int> safeToJson() => $ack.safeEncode(this);

  static Age _fromAckRuntime(int value) =>
      _$AgeFromJson(<String, dynamic>{'value': value});

  int _toAckRuntime() => _$AgeToJson(this)['value'] as int;

  static int _ackFromRuntimeValue(Object? value) => value as int;

  static Object? _ackToRuntimeValue(int value) => value;
}

/// Immutable value model generated from `priceSchema`.
@AckType.jsonSerializable
final class Price {
  Price(this.value);

  factory Price.parse(Object? input) {
    return $ack.parse(input);
  }

  factory Price.fromJson(double json) {
    return $ack.parse(json);
  }

  final double value;

  static final $ack = AckModelAdapter(
    schema: () => priceSchema,
    fromRuntime: Price._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<Price> safeParse(Object? input) => $ack.safeParse(input);

  double toJson() => $ack.encode(this);

  SchemaResult<double> safeToJson() => $ack.safeEncode(this);

  static Price _fromAckRuntime(double value) =>
      _$PriceFromJson(<String, dynamic>{'value': value});

  double _toAckRuntime() => _$PriceToJson(this)['value'] as double;

  static double _ackFromRuntimeValue(Object? value) => value as double;

  static Object? _ackToRuntimeValue(double value) => value;
}

/// Immutable value model generated from `activeSchema`.
@AckType.jsonSerializable
final class Active {
  Active(this.value);

  factory Active.parse(Object? input) {
    return $ack.parse(input);
  }

  factory Active.fromJson(bool json) {
    return $ack.parse(json);
  }

  final bool value;

  static final $ack = AckModelAdapter(
    schema: () => activeSchema,
    fromRuntime: Active._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<Active> safeParse(Object? input) => $ack.safeParse(input);

  bool toJson() => $ack.encode(this);

  SchemaResult<bool> safeToJson() => $ack.safeEncode(this);

  static Active _fromAckRuntime(bool value) =>
      _$ActiveFromJson(<String, dynamic>{'value': value});

  bool _toAckRuntime() => _$ActiveToJson(this)['value'] as bool;

  static bool _ackFromRuntimeValue(Object? value) => value as bool;

  static Object? _ackToRuntimeValue(bool value) => value;
}

/// Immutable value model generated from `tagsSchema`.
@AckType.jsonSerializable
final class Tags {
  Tags(List<String> value)
    : value = List<String>.unmodifiable(value.map((item) => item));

  factory Tags.parse(Object? input) {
    return $ack.parse(input);
  }

  factory Tags.fromJson(List<String> json) {
    return $ack.parse(json);
  }

  final List<String> value;

  static final $ack = AckModelAdapter(
    schema: () => tagsSchema,
    fromRuntime: Tags._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<Tags> safeParse(Object? input) => $ack.safeParse(input);

  List<String> toJson() => List<String>.of($ack.encode(this));

  SchemaResult<List<String>> safeToJson() => $ack.safeEncode(this);

  static Tags _fromAckRuntime(List<String> value) =>
      _$TagsFromJson(<String, dynamic>{'value': value});

  List<String> _toAckRuntime() => _$TagsToJson(this)['value'] as List<String>;

  static List<String> _ackFromRuntimeValue(Object? value) =>
      (value as List).map((item) => item as String).toList();

  static Object? _ackToRuntimeValue(List<String> value) =>
      value.map((item) => item).toList(growable: false);
}

/// Immutable value model generated from `scoresSchema`.
@AckType.jsonSerializable
final class Scores {
  Scores(List<int> value)
    : value = List<int>.unmodifiable(value.map((item) => item));

  factory Scores.parse(Object? input) {
    return $ack.parse(input);
  }

  factory Scores.fromJson(List<int> json) {
    return $ack.parse(json);
  }

  final List<int> value;

  static final $ack = AckModelAdapter(
    schema: () => scoresSchema,
    fromRuntime: Scores._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<Scores> safeParse(Object? input) => $ack.safeParse(input);

  List<int> toJson() => List<int>.of($ack.encode(this));

  SchemaResult<List<int>> safeToJson() => $ack.safeEncode(this);

  static Scores _fromAckRuntime(List<int> value) =>
      _$ScoresFromJson(<String, dynamic>{'value': value});

  List<int> _toAckRuntime() => _$ScoresToJson(this)['value'] as List<int>;

  static List<int> _ackFromRuntimeValue(Object? value) =>
      (value as List).map((item) => item as int).toList();

  static Object? _ackToRuntimeValue(List<int> value) =>
      value.map((item) => item).toList(growable: false);
}

/// Immutable value model generated from `statusSchema`.
@AckType.jsonSerializable
final class StatusLiteral {
  StatusLiteral(this.value);

  factory StatusLiteral.parse(Object? input) {
    return $ack.parse(input);
  }

  factory StatusLiteral.fromJson(String json) {
    return $ack.parse(json);
  }

  final String value;

  static final $ack = AckModelAdapter(
    schema: () => statusSchema,
    fromRuntime: StatusLiteral._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<StatusLiteral> safeParse(Object? input) =>
      $ack.safeParse(input);

  String toJson() => $ack.encode(this);

  SchemaResult<String> safeToJson() => $ack.safeEncode(this);

  static StatusLiteral _fromAckRuntime(String value) =>
      _$StatusLiteralFromJson(<String, dynamic>{'value': value});

  String _toAckRuntime() => _$StatusLiteralToJson(this)['value'] as String;

  static String _ackFromRuntimeValue(Object? value) => value as String;

  static Object? _ackToRuntimeValue(String value) => value;
}

/// Immutable value model generated from `roleSchema`.
@AckType.jsonSerializable
final class Role {
  Role(this.value);

  factory Role.parse(Object? input) {
    return $ack.parse(input);
  }

  factory Role.fromJson(String json) {
    return $ack.parse(json);
  }

  final String value;

  static final $ack = AckModelAdapter(
    schema: () => roleSchema,
    fromRuntime: Role._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<Role> safeParse(Object? input) => $ack.safeParse(input);

  String toJson() => $ack.encode(this);

  SchemaResult<String> safeToJson() => $ack.safeEncode(this);

  static Role _fromAckRuntime(String value) =>
      _$RoleFromJson(<String, dynamic>{'value': value});

  String _toAckRuntime() => _$RoleToJson(this)['value'] as String;

  static String _ackFromRuntimeValue(Object? value) => value as String;

  static Object? _ackToRuntimeValue(String value) => value;
}

/// Immutable value model generated from `userRoleSchema`.
@AckType.jsonSerializable
final class UserRoleModel {
  UserRoleModel(this.value);

  factory UserRoleModel.parse(Object? input) {
    return $ack.parse(input);
  }

  factory UserRoleModel.fromJson(String json) {
    return $ack.parse(json);
  }

  final UserRole value;

  static final $ack = AckModelAdapter(
    schema: () => userRoleSchema,
    fromRuntime: UserRoleModel._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<UserRoleModel> safeParse(Object? input) =>
      $ack.safeParse(input);

  String toJson() => $ack.encode(this);

  SchemaResult<String> safeToJson() => $ack.safeEncode(this);

  static UserRoleModel _fromAckRuntime(UserRole value) =>
      _$UserRoleModelFromJson(<String, dynamic>{'value': value});

  UserRole _toAckRuntime() => _$UserRoleModelToJson(this)['value'] as UserRole;

  static UserRole _ackFromRuntimeValue(Object? value) => value as UserRole;

  static Object? _ackToRuntimeValue(UserRole value) => value;
}

/// Immutable value model generated from `statusEnumSchema`.
@AckType.jsonSerializable
final class StatusEnum {
  StatusEnum(this.value);

  factory StatusEnum.parse(Object? input) {
    return $ack.parse(input);
  }

  factory StatusEnum.fromJson(String json) {
    return $ack.parse(json);
  }

  final Status value;

  static final $ack = AckModelAdapter(
    schema: () => statusEnumSchema,
    fromRuntime: StatusEnum._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<StatusEnum> safeParse(Object? input) =>
      $ack.safeParse(input);

  String toJson() => $ack.encode(this);

  SchemaResult<String> safeToJson() => $ack.safeEncode(this);

  static StatusEnum _fromAckRuntime(Status value) =>
      _$StatusEnumFromJson(<String, dynamic>{'value': value});

  Status _toAckRuntime() => _$StatusEnumToJson(this)['value'] as Status;

  static Status _ackFromRuntimeValue(Object? value) => value as Status;

  static Object? _ackToRuntimeValue(Status value) => value;
}

/// Immutable value model generated from `optionalStatusSchema`.
@AckType.jsonSerializable
final class OptionalStatus {
  OptionalStatus(this.value);

  factory OptionalStatus.parse(Object? input) {
    return $ack.parse(input);
  }

  factory OptionalStatus.fromJson(String json) {
    return $ack.parse(json);
  }

  final String value;

  static final $ack = AckModelAdapter(
    schema: () => optionalStatusSchema,
    fromRuntime: OptionalStatus._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<OptionalStatus> safeParse(Object? input) =>
      $ack.safeParse(input);

  String toJson() => $ack.encode(this);

  SchemaResult<String> safeToJson() => $ack.safeEncode(this);

  static OptionalStatus _fromAckRuntime(String value) =>
      _$OptionalStatusFromJson(<String, dynamic>{'value': value});

  String _toAckRuntime() => _$OptionalStatusToJson(this)['value'] as String;

  static String _ackFromRuntimeValue(Object? value) => value as String;

  static Object? _ackToRuntimeValue(String value) => value;
}

/// Immutable value model generated from `defaultedEnumSchema`.
@AckType.jsonSerializable
final class DefaultedEnum {
  DefaultedEnum(this.value);

  factory DefaultedEnum.parse(Object? input) {
    return $ack.parse(input);
  }

  factory DefaultedEnum.fromJson(String json) {
    return $ack.parse(json);
  }

  final UserRole value;

  static final $ack = AckModelAdapter(
    schema: () => defaultedEnumSchema,
    fromRuntime: DefaultedEnum._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<DefaultedEnum> safeParse(Object? input) =>
      $ack.safeParse(input);

  String toJson() => $ack.encode(this);

  SchemaResult<String> safeToJson() => $ack.safeEncode(this);

  static DefaultedEnum _fromAckRuntime(UserRole value) =>
      _$DefaultedEnumFromJson(<String, dynamic>{'value': value});

  UserRole _toAckRuntime() => _$DefaultedEnumToJson(this)['value'] as UserRole;

  static UserRole _ackFromRuntimeValue(Object? value) => value as UserRole;

  static Object? _ackToRuntimeValue(UserRole value) => value;
}

/// Immutable value model generated from `chainedEnumStringSchema`.
@AckType.jsonSerializable
final class ChainedEnumString {
  ChainedEnumString(this.value);

  factory ChainedEnumString.parse(Object? input) {
    return $ack.parse(input);
  }

  factory ChainedEnumString.fromJson(String json) {
    return $ack.parse(json);
  }

  final String value;

  static final $ack = AckModelAdapter(
    schema: () => chainedEnumStringSchema,
    fromRuntime: ChainedEnumString._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<ChainedEnumString> safeParse(Object? input) =>
      $ack.safeParse(input);

  String toJson() => $ack.encode(this);

  SchemaResult<String> safeToJson() => $ack.safeEncode(this);

  static ChainedEnumString _fromAckRuntime(String value) =>
      _$ChainedEnumStringFromJson(<String, dynamic>{'value': value});

  String _toAckRuntime() => _$ChainedEnumStringToJson(this)['value'] as String;

  static String _ackFromRuntimeValue(Object? value) => value as String;

  static Object? _ackToRuntimeValue(String value) => value;
}

/// Immutable value model generated from `refinedAgeSchema`.
@AckType.jsonSerializable
final class RefinedAge {
  RefinedAge(this.value);

  factory RefinedAge.parse(Object? input) {
    return $ack.parse(input);
  }

  factory RefinedAge.fromJson(int json) {
    return $ack.parse(json);
  }

  final int value;

  static final $ack = AckModelAdapter(
    schema: () => refinedAgeSchema,
    fromRuntime: RefinedAge._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<RefinedAge> safeParse(Object? input) =>
      $ack.safeParse(input);

  int toJson() => $ack.encode(this);

  SchemaResult<int> safeToJson() => $ack.safeEncode(this);

  static RefinedAge _fromAckRuntime(int value) =>
      _$RefinedAgeFromJson(<String, dynamic>{'value': value});

  int _toAckRuntime() => _$RefinedAgeToJson(this)['value'] as int;

  static int _ackFromRuntimeValue(Object? value) => value as int;

  static Object? _ackToRuntimeValue(int value) => value;
}
