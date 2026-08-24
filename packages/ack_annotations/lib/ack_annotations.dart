/// Annotation library for Ack schema model-class generation.
///
/// Import this library to use `@AckType()` on top-level schema declarations or
/// `@AckModel()` on hand-written model classes processed by `ack_generator`.
library;

export 'package:json_annotation/json_annotation.dart' show JsonKey;
export 'src/ack_field.dart';
export 'src/ack_model.dart';
export 'src/ack_type.dart';
export 'src/constraints.dart';
