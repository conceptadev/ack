// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'schema_types_simple.dart';

// **************************************************************************
// AckSchemaGenerator
// **************************************************************************

/// Immutable model generated from `userSchema`.
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

  static User _fromAckRuntime(Map<String, Object?> value) {
    return User(
      name: value['name'] as String,
      age: value['age'] as int,
      active: value['active'] as bool,
    );
  }

  Map<String, Object?> _toAckRuntime() {
    return <String, Object?>{'name': name, 'age': age, 'active': active};
  }
}
