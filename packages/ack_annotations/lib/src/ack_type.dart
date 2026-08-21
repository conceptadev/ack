import 'package:meta/meta_meta.dart';

import 'ack_generated_json.dart';

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
/// The declaring library must include both generated parts, for example
/// `part 'user.ack.dart';` and `part 'user.g.dart';`. `ack_generator` emits
/// the model class, public parse/JSON API, and runtime bridges in the Ack
/// part. Structural field mapping is generated into the combined JSON part.
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
  /// Internal marker used on generated model classes.
  ///
  /// Typed as [Object] so generated code only needs a constant annotation
  /// expression. The generator inspects the actual [AckGeneratedJson] type.
  static const Object jsonSerializable = AckGeneratedJson();

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
  /// [name] must be an unchanged UpperCamelCase Dart identifier. It is used
  /// exactly; a `Type` suffix is retained when intentionally supplied.
  const AckType({this.name});
}
