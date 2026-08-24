# Class-first model generation

Use `@AckModel()` when you want to own the Dart class and derive its Ack schema.
The generator keeps the class unchanged and emits a codec schema, JSON mapping
helpers, and `toJson` / `safeToJson` extension methods.

```dart
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

part 'profile.ack.dart';
part 'profile.g.dart';

@AckModel(caseStyle: AckCaseStyle.snake)
final class Profile {
  const Profile({
    required this.displayName,
    this.website,
    this.role = 'member',
  });

  @MinLength(2)
  final String displayName;
  final Uri? website;
  final String role;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      profileSchema.parse(json)!;
}
```

Run `dart run build_runner build`. `profileSchema` is an
`AckSchema<Map<String, Object?>, Profile>`: parsing validates the JSON boundary
and constructs `Profile`, while encoding validates a model and returns JSON.
The `fromJson` forwarder is optional and remains user-written.

## Fields and presence

Ack derives presence from constructor parameters and field types:

- `required T` is required;
- `required T?` is required and nullable, and encodes an explicit `null`;
- optional `T?` may be omitted and is omitted on encode when null;
- a constructor default becomes `.withDefault(...)`.

Built-in inference covers scalar Dart types, enums, recursively nested lists,
and sets. Sets use a list codec. Use `@AckField(schema: mySchema)` with a const
tear-off of a top-level `AckSchema Function()` for custom runtime types and
`Map<String, V>` fields. Non-String map keys and fields without a concrete
static contract are rejected at generation time.

Constraint annotations are type-scoped: numeric fields accept `@Min`, `@Max`,
`@MultipleOf`, `@Positive`, and `@Negative`; strings accept `@MinLength`,
`@MaxLength`, `@Pattern`, `@Email`, and `@NotEmpty`; lists and sets accept
`@MinItems`, `@MaxItems`, and `@UniqueItems`.

Use `caseStyle` for a model-wide key style and `@JsonKey(name: ...)` for one
field. Ack feeds the same resolved keys to schema generation and JSON mapping.

## Sealed unions

An annotated sealed base requires a discriminator key. Concrete same-library
branches are included automatically, and super parameters resolve inherited
fields:

```dart
@AckModel(discriminatorKey: 'type')
sealed class Pet {
  const Pet({required this.id});
  final String id;
}

@AckModel(discriminatorValue: 'cat')
final class Cat extends Pet {
  const Cat({required super.id, required this.lives});
  final int lives;
}
```

An omitted `discriminatorValue` uses the verbatim class name. Explicit values
are preferable for wire stability. Undiscriminated `anyOf` models and value
roots remain schema-first concerns.

## Additional properties

`@AckModel(additionalProperties: true)` requires a declared
`Map<String, Object?> additionalProperties` field initialized by the
constructor. Unknown keys are stored there. Encoding writes extras first, so
declared fields and union discriminators cannot be spoofed.

## Choosing class-first or schema-first

Choose class-first when a hand-written domain class is the primary artifact
and its fields provide the schema shape. Choose schema-first `@AckType()` when
the boundary schema is primary, when Ack should generate the immutable model,
or for scalar/collection roots, named recursion, and undiscriminated schema
composition. Both styles can coexist in one library with ordinary
`@JsonSerializable` classes, but one class cannot carry both `@AckModel` and
`@JsonSerializable`.

For larger repositories, restrict both Ack builder phases with matching
`generate_for` entries. This reduces analyzer work and ensures the `.ack.dart`
input is generated before Ack's JSON phase for the same libraries:

```yaml
targets:
  $default:
    builders:
      ack_generator|ack_generator:
        generate_for: [lib/models/**.dart]
      ack_generator|ack_json_serializable:
        generate_for: [lib/models/**.dart]
```
