import 'package:meta/meta_meta.dart';

/// Overrides inferred input-presence for a class-first field.
///
/// [inferred] keeps constructor-based presence. [required] always requires the
/// JSON key. [optional] is valid only when the constructor can accept a missing
/// value, with a discriminator-specific exception for union branches.
enum AckFieldPresence { inferred, required, optional }

/// Overrides the inferred schema and/or presence for a class-first field.
///
/// [schema] must be a const tear-off of a top-level function returning an Ack
/// schema. The generator validates the declaration and follows its expression.
/// A no-op `@AckField()` is rejected.
@Target({TargetKind.field})
final class AckField {
  /// Creates a field annotation.
  const AckField({this.schema, this.presence = AckFieldPresence.inferred});

  /// Top-level schema-function tear-off followed by `ack_generator`.
  final Object Function()? schema;

  /// Presence override applied after constructor inference.
  final AckFieldPresence presence;
}
