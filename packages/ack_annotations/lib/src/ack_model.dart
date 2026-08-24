import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta_meta.dart';

/// JSON field-name styles supported by class-first Ack generation.
///
/// This enum is deliberately closed because Ack's second generation phase
/// delegates field mapping to json_serializable's closed `FieldRename` enum.
/// Supporting an open-ended transform would require redesigning that phase.
enum AckCaseStyle { none, snake, kebab, pascal, screamingSnake }

/// Marks a hand-written class for Ack schema generation.
///
/// The declaring library must include both generated parts, for example
/// `part 'user.ack.dart';` and `part 'user.g.dart';`.
@Target({TargetKind.classType})
final class AckModel {
  /// Creates a class-first Ack model annotation.
  const AckModel({
    this.schemaName,
    this.caseStyle = AckCaseStyle.none,
    this.discriminatorKey,
    this.discriminatorValue,
    this.additionalProperties = false,
  }) : // A switch expression is not const-evaluable in a const constructor.
       jsonSerializable = caseStyle == AckCaseStyle.snake
           ? const JsonSerializable(
               includeIfNull: false,
               fieldRename: FieldRename.snake,
             )
           : caseStyle == AckCaseStyle.kebab
           ? const JsonSerializable(
               includeIfNull: false,
               fieldRename: FieldRename.kebab,
             )
           : caseStyle == AckCaseStyle.pascal
           ? const JsonSerializable(
               includeIfNull: false,
               fieldRename: FieldRename.pascal,
             )
           : caseStyle == AckCaseStyle.screamingSnake
           ? const JsonSerializable(
               includeIfNull: false,
               fieldRename: FieldRename.screamingSnake,
             )
           : const JsonSerializable(
               includeIfNull: false,
               fieldRename: FieldRename.none,
             );

  /// Exact generated schema name, or `null` to derive `<lowerCamel>Schema`.
  final String? schemaName;

  /// Naming convention applied to JSON field keys.
  final AckCaseStyle caseStyle;

  /// Required discriminator key for an annotated sealed union base.
  final String? discriminatorKey;

  /// Wire discriminator for a concrete union branch.
  ///
  /// When omitted, the verbatim class name is used.
  final String? discriminatorValue;

  /// Whether undeclared object properties are preserved.
  final bool additionalProperties;

  /// Fixed phase-2 configuration consumed by `ack_generator`.
  ///
  /// This remains derived from [caseStyle], so users cannot independently
  /// configure schema keys and JSON mapping.
  final JsonSerializable jsonSerializable;
}
