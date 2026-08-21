# ack_annotations

`ack_annotations` provides the `@AckType()` annotation used by
`ack_generator`.

## Installation

```yaml
dependencies:
  ack: ^1.0.0
  ack_annotations: ^1.0.0

dev_dependencies:
  ack_generator: ^1.0.0
  build_runner: ^2.4.0
```

## Usage

Annotate a top-level Ack schema variable or getter and run `build_runner`:

```dart
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

part 'user.ack.dart';

@AckType()
final userSchema = Ack.object({
  'name': Ack.string(),
  'email': Ack.string().email(),
});
```

`ack_generator` emits an immutable `User` class with typed fields, an unchecked
constructor, parsing helpers, JSON methods, and a public `$ack` adapter.

Generate the wrapper with:

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
