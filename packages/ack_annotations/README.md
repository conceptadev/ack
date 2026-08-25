# ack_annotations

`ack_annotations` provides the `@AckType()` schema-first and `@AckModel()`
class-first annotations used by `ack_generator`.

## Installation

```yaml
dependencies:
  ack: ^2.0.0
  ack_annotations: ^2.0.0

dev_dependencies:
  ack_generator: ^2.0.0
  build_runner: ^2.4.0
```

## Usage

Annotate a top-level Ack schema variable or getter and run `build_runner`:

```dart
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

part 'user.ack.dart';
part 'user.g.dart';

@AckType()
final userSchema = Ack.object({
  'name': Ack.string(),
  'email': Ack.string().email(),
});
```

`ack_generator` emits an immutable `User` class with typed fields, an unchecked
constructor, parsing helpers, JSON methods, generated `copyWith`, deep
collection-aware equality, and a public `$ack` adapter. The Ack part owns those
declarations; `json_serializable` writes the structural field-mapping helpers
into `user.g.dart`. Ack-only apps do not add JSON packages for generated
models. The annotation package requires Dart 3.9.

Generate the model with:

```bash
dart run build_runner build
```

## Custom names

Use `name` to set the exact generated class name:

```dart
@AckType(name: 'Password')
final passwordSchema = Ack.string().minLength(8);
```

This generates `Password`. Names must be unchanged UpperCamelCase identifiers;
an intentional `Type` suffix is kept exactly.

## Supported targets

- Top-level schema variables
- Top-level schema getters

`@AckType()` is not supported on classes or instance members.

`@AckModel()` targets a public, constructable class and derives an Ack codec
schema from its constructor-backed fields. Instantiable models apply the
generated `_$ClassAck` mixin. The public `<ClassName>Schema` facade exposes
typed `schema` and raw `wireSchema`; `schemaName:` overrides the exact facade
class name and must be UpperCamelCase.

Unknown properties use `AckAdditionalPropertiesMode` (`reject`, `discard`,
`capture`). `@AckField` can override `schema` and/or `AckFieldPresence`. See the
[Model Code Generation guide](../../docs/core-concepts/typesafe-schemas.mdx).
