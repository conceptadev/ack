import 'package:json_annotation/json_annotation.dart';

/// Generator-support marker applied to Ack-generated model classes.
///
/// This is not part of the user-facing annotation API. `ack_generator` emits
/// [AckType.jsonSerializable] so the internal JSON builder can delegate
/// structural mapping to `json_serializable` without a literal
/// `@JsonSerializable` annotation that the ordinary builder would also claim.
class AckGeneratedJson {
  /// Creates the internal JSON-mapping marker.
  const AckGeneratedJson({
    this.config = const JsonSerializable(includeIfNull: false),
  });

  /// Fixed `json_serializable` configuration owned by Ack.
  ///
  /// `includeIfNull` is always `false` so optional null fields stay absent.
  /// Required nullable keys are restored by generated Ack glue.
  final JsonSerializable config;
}
