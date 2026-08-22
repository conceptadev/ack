// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'args_getter_example.dart';

// **************************************************************************
// AckSchemaGenerator
// **************************************************************************

/// Immutable model generated from `userConfigSchema`.
@AckType.jsonSerializable
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
@AckType.jsonSerializable
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
@AckType.jsonSerializable
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
@AckType.jsonSerializable
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
