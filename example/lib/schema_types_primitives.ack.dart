// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'schema_types_primitives.dart';

// **************************************************************************
// AckSchemaGenerator
// **************************************************************************

/// Immutable value model generated from `passwordSchema`.
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

  static Password _fromAckRuntime(String value) => Password(value);

  String _toAckRuntime() => value;
}

/// Immutable value model generated from `ageSchema`.
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

  static Age _fromAckRuntime(int value) => Age(value);

  int _toAckRuntime() => value;
}

/// Immutable value model generated from `priceSchema`.
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

  static Price _fromAckRuntime(double value) => Price(value);

  double _toAckRuntime() => value;
}

/// Immutable value model generated from `activeSchema`.
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

  static Active _fromAckRuntime(bool value) => Active(value);

  bool _toAckRuntime() => value;
}

/// Immutable value model generated from `tagsSchema`.
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

  List<String> toJson() => $ack.encode(this);

  SchemaResult<List<String>> safeToJson() => $ack.safeEncode(this);

  static Tags _fromAckRuntime(List<String> value) => Tags(value);

  List<String> _toAckRuntime() => value;
}

/// Immutable value model generated from `scoresSchema`.
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

  List<int> toJson() => $ack.encode(this);

  SchemaResult<List<int>> safeToJson() => $ack.safeEncode(this);

  static Scores _fromAckRuntime(List<int> value) => Scores(value);

  List<int> _toAckRuntime() => value;
}

/// Immutable value model generated from `statusSchema`.
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

  static StatusLiteral _fromAckRuntime(String value) => StatusLiteral(value);

  String _toAckRuntime() => value;
}

/// Immutable value model generated from `roleSchema`.
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

  static Role _fromAckRuntime(String value) => Role(value);

  String _toAckRuntime() => value;
}

/// Immutable value model generated from `userRoleSchema`.
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

  static UserRoleModel _fromAckRuntime(UserRole value) => UserRoleModel(value);

  UserRole _toAckRuntime() => value;
}

/// Immutable value model generated from `statusEnumSchema`.
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

  static StatusEnum _fromAckRuntime(Status value) => StatusEnum(value);

  Status _toAckRuntime() => value;
}

/// Immutable value model generated from `optionalStatusSchema`.
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

  static OptionalStatus _fromAckRuntime(String value) => OptionalStatus(value);

  String _toAckRuntime() => value;
}

/// Immutable value model generated from `defaultedEnumSchema`.
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

  static DefaultedEnum _fromAckRuntime(UserRole value) => DefaultedEnum(value);

  UserRole _toAckRuntime() => value;
}

/// Immutable value model generated from `chainedEnumStringSchema`.
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
      ChainedEnumString(value);

  String _toAckRuntime() => value;
}

/// Immutable value model generated from `refinedAgeSchema`.
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

  static RefinedAge _fromAckRuntime(int value) => RefinedAge(value);

  int _toAckRuntime() => value;
}
