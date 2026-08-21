// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'schema_types_simple.dart';

// **************************************************************************
// AckSchemaGenerator
// **************************************************************************

/// Immutable model generated from `userSchema`.
@AckType.jsonSerializable
final class User {
  User({required this.name, required this.age, required this.active});

  factory User.parse(Object? input) {
    return $ack.parse(input);
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return $ack.parse(json);
  }

  final String name;

  final int age;

  final bool active;

  static final $ack = AckModelAdapter(
    schema: () => userSchema,
    fromRuntime: User._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<User> safeParse(Object? input) => $ack.safeParse(input);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from($ack.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() => $ack.safeEncode(this);

  static User _fromAckRuntime(Map<String, Object?> value) =>
      _$UserFromJson(Map<String, dynamic>.from(value));

  Map<String, Object?> _toAckRuntime() => <String, Object?>{
    ..._$UserToJson(this),
  };

  static String _ackFromRuntimeName(Object? value) => value as String;

  static Object? _ackToRuntimeName(String value) => value;

  static int _ackFromRuntimeAge(Object? value) => value as int;

  static Object? _ackToRuntimeAge(int value) => value;

  static bool _ackFromRuntimeActive(Object? value) => value as bool;

  static Object? _ackToRuntimeActive(bool value) => value;
}
