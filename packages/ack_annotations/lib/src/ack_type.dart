import 'package:meta/meta_meta.dart';

/// Marks a top-level Ack schema for immutable model-class generation.
///
/// Apply `@AckType()` to a top-level schema variable or getter:
///
/// ```dart
/// @AckType()
/// final userSchema = Ack.object({
///   'name': Ack.string(),
///   'age': Ack.integer(),
/// });
/// ```
///
/// `ack_generator` emits a real Dart class with stored typed fields plus
/// `parse`, `safeParse`, `fromMap`, `fromJson`, `toMap`, and `toJson` APIs.
/// Ack remains responsible for validation and codec-aware serialization.
///
/// Supported targets:
/// - Top-level variables
/// - Top-level getters
///
/// `meta` cannot express "top-level getter only", so the annotation allows all
/// getters and `ack_generator` enforces the top-level restriction.
///
/// Unsupported targets:
/// - Classes
/// - Instance members
/// - Local variables
@Target({TargetKind.topLevelVariable, TargetKind.getter})
class AckType {
  /// Optional exact name for the generated model class.
  ///
  /// If omitted, the class name is derived from the schema declaration:
  /// - `userSchema` -> `User`
  /// - `passwordSchema` -> `Password`
  ///
  /// If provided, the value is used directly:
  /// - `@AckType(name: 'AppUser')` -> `AppUser`
  final String? name;

  /// Creates an annotation for immutable Ack model generation.
  ///
  /// [name] must be a valid Dart class identifier. Do not add a `Type` suffix
  /// unless it is intentionally part of the public model name.
  const AckType({this.name});
}
