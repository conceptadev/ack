// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'args_getter_example.dart';

// **************************************************************************
// AckSchemaGenerator
// **************************************************************************

/// Immutable model generated from `userConfigSchema`.
final class UserConfig {
  UserConfig({
    required this.username,
    required this.email,
    Map<String, Object?> additionalProperties = const {},
  }) : additionalProperties = _ackImmutableCopyMap(additionalProperties);

  factory UserConfig.parse(Object? input) {
    return $ack.parse(input);
  }

  factory UserConfig.fromJson(Map<String, dynamic> json) {
    return $ack.parse(json);
  }

  final String username;

  final String email;

  /// Properties accepted by a schema with additional properties.
  final Map<String, Object?> additionalProperties;

  static final $ack = AckModelAdapter(
    schema: () => userConfigSchema,
    fromRuntime: UserConfig._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<UserConfig> safeParse(Object? input) =>
      $ack.safeParse(input);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from($ack.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() => $ack.safeEncode(this);

  static UserConfig _fromAckRuntime(Map<String, Object?> value) {
    return UserConfig(
      username: value['username'] as String,
      email: value['email'] as String,
      additionalProperties: _ackImmutableCopyMap(
        Map<String, Object?>.fromEntries(
          value.entries.where(
            (entry) => !const <String>{'username', 'email'}.contains(entry.key),
          ),
        ),
      ),
    );
  }

  Map<String, Object?> _toAckRuntime() {
    return <String, Object?>{
      ...additionalProperties,
      'username': username,
      'email': email,
    };
  }
}

/// Immutable model generated from `apiRequestSchema`.
final class ApiRequest {
  ApiRequest({
    required this.method,
    required this.url,
    Map<String, Object?> additionalProperties = const {},
  }) : additionalProperties = _ackImmutableCopyMap(additionalProperties);

  factory ApiRequest.parse(Object? input) {
    return $ack.parse(input);
  }

  factory ApiRequest.fromJson(Map<String, dynamic> json) {
    return $ack.parse(json);
  }

  final String method;

  final String url;

  /// Properties accepted by a schema with additional properties.
  final Map<String, Object?> additionalProperties;

  static final $ack = AckModelAdapter(
    schema: () => apiRequestSchema,
    fromRuntime: ApiRequest._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<ApiRequest> safeParse(Object? input) =>
      $ack.safeParse(input);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from($ack.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() => $ack.safeEncode(this);

  static ApiRequest _fromAckRuntime(Map<String, Object?> value) {
    return ApiRequest(
      method: value['method'] as String,
      url: value['url'] as String,
      additionalProperties: _ackImmutableCopyMap(
        Map<String, Object?>.fromEntries(
          value.entries.where(
            (entry) => !const <String>{'method', 'url'}.contains(entry.key),
          ),
        ),
      ),
    );
  }

  Map<String, Object?> _toAckRuntime() {
    return <String, Object?>{
      ...additionalProperties,
      'method': method,
      'url': url,
    };
  }
}

/// Immutable model generated from `featureFlagsSchema`.
final class FeatureFlags {
  FeatureFlags({
    required this.appVersion,
    required this.environment,
    Map<String, Object?> additionalProperties = const {},
  }) : additionalProperties = _ackImmutableCopyMap(additionalProperties);

  factory FeatureFlags.parse(Object? input) {
    return $ack.parse(input);
  }

  factory FeatureFlags.fromJson(Map<String, dynamic> json) {
    return $ack.parse(json);
  }

  final String appVersion;

  final String environment;

  /// Properties accepted by a schema with additional properties.
  final Map<String, Object?> additionalProperties;

  static final $ack = AckModelAdapter(
    schema: () => featureFlagsSchema,
    fromRuntime: FeatureFlags._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<FeatureFlags> safeParse(Object? input) =>
      $ack.safeParse(input);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from($ack.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() => $ack.safeEncode(this);

  static FeatureFlags _fromAckRuntime(Map<String, Object?> value) {
    return FeatureFlags(
      appVersion: value['appVersion'] as String,
      environment: value['environment'] as String,
      additionalProperties: _ackImmutableCopyMap(
        Map<String, Object?>.fromEntries(
          value.entries.where(
            (entry) => !const <String>{
              'appVersion',
              'environment',
            }.contains(entry.key),
          ),
        ),
      ),
    );
  }

  Map<String, Object?> _toAckRuntime() {
    return <String, Object?>{
      ...additionalProperties,
      'appVersion': appVersion,
      'environment': environment,
    };
  }
}

/// Immutable model generated from `dynamicDataSchema`.
final class DynamicData {
  DynamicData({Map<String, Object?> additionalProperties = const {}})
    : additionalProperties = _ackImmutableCopyMap(additionalProperties);

  factory DynamicData.parse(Object? input) {
    return $ack.parse(input);
  }

  factory DynamicData.fromJson(Map<String, dynamic> json) {
    return $ack.parse(json);
  }

  /// Properties accepted by a schema with additional properties.
  final Map<String, Object?> additionalProperties;

  static final $ack = AckModelAdapter(
    schema: () => dynamicDataSchema,
    fromRuntime: DynamicData._fromAckRuntime,
    toRuntime: (model) => model._toAckRuntime(),
  );

  static SchemaResult<DynamicData> safeParse(Object? input) =>
      $ack.safeParse(input);

  Map<String, dynamic> toJson() => Map<String, dynamic>.from($ack.encode(this));

  SchemaResult<Map<String, Object?>> safeToJson() => $ack.safeEncode(this);

  static DynamicData _fromAckRuntime(Map<String, Object?> value) {
    return DynamicData(additionalProperties: _ackImmutableCopyMap(value));
  }

  Map<String, Object?> _toAckRuntime() {
    return <String, Object?>{...additionalProperties};
  }
}

Object? _ackImmutableCopyValue(Object? value) => switch (value) {
  List() => List.unmodifiable(value.map(_ackImmutableCopyValue)),
  Set() => Set.unmodifiable(value.map(_ackImmutableCopyValue)),
  Map() => Map.unmodifiable(
    value.map((key, item) => MapEntry(key, _ackImmutableCopyValue(item))),
  ),
  _ => value,
};
Map<String, Object?> _ackImmutableCopyMap(Map<String, Object?> value) =>
    Map.unmodifiable(
      value.map((key, item) => MapEntry(key, _ackImmutableCopyValue(item))),
    );
