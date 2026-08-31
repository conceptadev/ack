/// Annotation library for Ack schema model-class generation.
///
/// Import this library to use `@AckInfer()` on top-level schema declarations or
/// `@AckModel()` on hand-written model classes processed by `ack_generator`.
///
/// Class-first models apply the generated `_$ClassAck` mixin and may use
/// [AckUnknownPropertyPolicy] and [AckFieldPresence] to describe wire
/// extras and field presence.
library;

export 'package:json_annotation/json_annotation.dart' show JsonKey;
export 'src/ack_field.dart';
export 'src/ack_infer.dart';
export 'src/ack_model.dart';
export 'src/constraints.dart';
