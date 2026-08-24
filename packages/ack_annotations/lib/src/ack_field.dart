import 'package:meta/meta_meta.dart';

/// Overrides the inferred schema for a class-first model field.
///
/// [schema] must be a const tear-off of a top-level function returning an Ack
/// schema. The generator validates the declaration and follows its expression.
@Target({TargetKind.field})
final class AckField {
  /// Creates an escape-hatch field annotation.
  const AckField({required this.schema});

  /// Top-level schema-function tear-off followed by `ack_generator`.
  final Object Function() schema;
}
