// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'additional_properties_example.dart';

// **************************************************************************
// AckModelGenerator
// **************************************************************************

/// Immutable model generated from `userConfigSchema`.
@AckInfer.jsonSerializable
final class UserConfig {
  UserConfig({
    required this.username,
    required this.email,
    Map<String, Object?> additionalProperties = const {},
  }) : additionalProperties = deepUnmodifiableJsonMap(additionalProperties);

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

  UserConfig copyWith({
    String? username,
    String? email,
    Map<String, Object?>? additionalProperties,
  }) => UserConfig(
    username: username ?? this.username,
    email: email ?? this.email,
    additionalProperties: additionalProperties ?? this.additionalProperties,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserConfig &&
          runtimeType == other.runtimeType &&
          deepEquals(username, other.username) &&
          deepEquals(email, other.email) &&
          deepEquals(additionalProperties, other.additionalProperties));

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    deepHashCode(username),
    deepHashCode(email),
    deepHashCode(additionalProperties),
  ]);

  @override
  String toString() =>
      'UserConfig(username: $username, email: $email, additionalProperties: $additionalProperties)';

  static UserConfig _fromAckRuntime(Map<String, Object?> value) {
    const declared = <String>{'username', 'email'};
    return _$UserConfigFromJson(<String, dynamic>{
      ...value,
      'additionalProperties': Map<String, Object?>.fromEntries(
        value.entries.where((entry) => !declared.contains(entry.key)),
      ),
    });
  }

  Map<String, Object?> _toAckRuntime() {
    const declared = <String>{'username', 'email'};
    final result = <String, Object?>{..._$UserConfigToJson(this)};
    result.remove('additionalProperties');
    return <String, Object?>{
      for (final entry in additionalProperties.entries)
        if (!declared.contains(entry.key)) entry.key: entry.value,
      ...result,
    };
  }

  static String _ackFromRuntimeUsername(Object? value) => value as String;

  static Object? _ackToRuntimeUsername(String value) => value;

  static String _ackFromRuntimeEmail(Object? value) => value as String;

  static Object? _ackToRuntimeEmail(String value) => value;

  static Map<String, Object?>? _ackFromRuntimeAdditionalProperties(
    Object? value,
  ) => value as Map<String, Object?>?;

  static Object? _ackToRuntimeAdditionalProperties(
    Map<String, Object?> value,
  ) => value;
}

/// Immutable model generated from `apiRequestSchema`.
@AckInfer.jsonSerializable
final class ApiRequest {
  ApiRequest({
    required this.method,
    required this.url,
    Map<String, Object?> additionalProperties = const {},
  }) : additionalProperties = deepUnmodifiableJsonMap(additionalProperties);

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

  ApiRequest copyWith({
    String? method,
    String? url,
    Map<String, Object?>? additionalProperties,
  }) => ApiRequest(
    method: method ?? this.method,
    url: url ?? this.url,
    additionalProperties: additionalProperties ?? this.additionalProperties,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ApiRequest &&
          runtimeType == other.runtimeType &&
          deepEquals(method, other.method) &&
          deepEquals(url, other.url) &&
          deepEquals(additionalProperties, other.additionalProperties));

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    deepHashCode(method),
    deepHashCode(url),
    deepHashCode(additionalProperties),
  ]);

  @override
  String toString() =>
      'ApiRequest(method: $method, url: $url, additionalProperties: $additionalProperties)';

  static ApiRequest _fromAckRuntime(Map<String, Object?> value) {
    const declared = <String>{'method', 'url'};
    return _$ApiRequestFromJson(<String, dynamic>{
      ...value,
      'additionalProperties': Map<String, Object?>.fromEntries(
        value.entries.where((entry) => !declared.contains(entry.key)),
      ),
    });
  }

  Map<String, Object?> _toAckRuntime() {
    const declared = <String>{'method', 'url'};
    final result = <String, Object?>{..._$ApiRequestToJson(this)};
    result.remove('additionalProperties');
    return <String, Object?>{
      for (final entry in additionalProperties.entries)
        if (!declared.contains(entry.key)) entry.key: entry.value,
      ...result,
    };
  }

  static String _ackFromRuntimeMethod(Object? value) => value as String;

  static Object? _ackToRuntimeMethod(String value) => value;

  static String _ackFromRuntimeUrl(Object? value) => value as String;

  static Object? _ackToRuntimeUrl(String value) => value;

  static Map<String, Object?>? _ackFromRuntimeAdditionalProperties(
    Object? value,
  ) => value as Map<String, Object?>?;

  static Object? _ackToRuntimeAdditionalProperties(
    Map<String, Object?> value,
  ) => value;
}

/// Immutable model generated from `featureFlagsSchema`.
@AckInfer.jsonSerializable
final class FeatureFlags {
  FeatureFlags({
    required this.appVersion,
    required this.environment,
    Map<String, Object?> additionalProperties = const {},
  }) : additionalProperties = deepUnmodifiableJsonMap(additionalProperties);

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

  FeatureFlags copyWith({
    String? appVersion,
    String? environment,
    Map<String, Object?>? additionalProperties,
  }) => FeatureFlags(
    appVersion: appVersion ?? this.appVersion,
    environment: environment ?? this.environment,
    additionalProperties: additionalProperties ?? this.additionalProperties,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeatureFlags &&
          runtimeType == other.runtimeType &&
          deepEquals(appVersion, other.appVersion) &&
          deepEquals(environment, other.environment) &&
          deepEquals(additionalProperties, other.additionalProperties));

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    deepHashCode(appVersion),
    deepHashCode(environment),
    deepHashCode(additionalProperties),
  ]);

  @override
  String toString() =>
      'FeatureFlags(appVersion: $appVersion, environment: $environment, additionalProperties: $additionalProperties)';

  static FeatureFlags _fromAckRuntime(Map<String, Object?> value) {
    const declared = <String>{'appVersion', 'environment'};
    return _$FeatureFlagsFromJson(<String, dynamic>{
      ...value,
      'additionalProperties': Map<String, Object?>.fromEntries(
        value.entries.where((entry) => !declared.contains(entry.key)),
      ),
    });
  }

  Map<String, Object?> _toAckRuntime() {
    const declared = <String>{'appVersion', 'environment'};
    final result = <String, Object?>{..._$FeatureFlagsToJson(this)};
    result.remove('additionalProperties');
    return <String, Object?>{
      for (final entry in additionalProperties.entries)
        if (!declared.contains(entry.key)) entry.key: entry.value,
      ...result,
    };
  }

  static String _ackFromRuntimeAppVersion(Object? value) => value as String;

  static Object? _ackToRuntimeAppVersion(String value) => value;

  static String _ackFromRuntimeEnvironment(Object? value) => value as String;

  static Object? _ackToRuntimeEnvironment(String value) => value;

  static Map<String, Object?>? _ackFromRuntimeAdditionalProperties(
    Object? value,
  ) => value as Map<String, Object?>?;

  static Object? _ackToRuntimeAdditionalProperties(
    Map<String, Object?> value,
  ) => value;
}

/// Immutable model generated from `dynamicDataSchema`.
@AckInfer.jsonSerializable
final class DynamicData {
  DynamicData({Map<String, Object?> additionalProperties = const {}})
    : additionalProperties = deepUnmodifiableJsonMap(additionalProperties);

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

  DynamicData copyWith({Map<String, Object?>? additionalProperties}) =>
      DynamicData(
        additionalProperties: additionalProperties ?? this.additionalProperties,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DynamicData &&
          runtimeType == other.runtimeType &&
          deepEquals(additionalProperties, other.additionalProperties));

  @override
  int get hashCode =>
      Object.hashAll([runtimeType, deepHashCode(additionalProperties)]);

  @override
  String toString() =>
      'DynamicData(additionalProperties: $additionalProperties)';

  static DynamicData _fromAckRuntime(Map<String, Object?> value) {
    const declared = <String>{};
    return _$DynamicDataFromJson(<String, dynamic>{
      ...value,
      'additionalProperties': Map<String, Object?>.fromEntries(
        value.entries.where((entry) => !declared.contains(entry.key)),
      ),
    });
  }

  Map<String, Object?> _toAckRuntime() {
    const declared = <String>{};
    final result = <String, Object?>{..._$DynamicDataToJson(this)};
    result.remove('additionalProperties');
    return <String, Object?>{
      for (final entry in additionalProperties.entries)
        if (!declared.contains(entry.key)) entry.key: entry.value,
      ...result,
    };
  }

  static Map<String, Object?>? _ackFromRuntimeAdditionalProperties(
    Object? value,
  ) => value as Map<String, Object?>?;

  static Object? _ackToRuntimeAdditionalProperties(
    Map<String, Object?> value,
  ) => value;
}
