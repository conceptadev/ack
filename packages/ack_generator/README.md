# Ack Generator

`ack_generator` generates immutable Dart model classes from top-level Ack
schemas annotated with `@AckType()`.

> This branch contains a draft class-generation rewrite. See
> [`docs/architecture/acktype-model-generation.md`](../../docs/architecture/acktype-model-generation.md)
> for design decisions, known gaps, and the validation checklist.

## Overview

```dart
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

part 'user_schema.g.dart';

@AckType()
final userSchema = Ack.object({
  'name': Ack.string(),
  'email': Ack.string().email(),
});
```

Running `dart run build_runner build` generates a real class:

```dart
final class User {
  User({required this.name, required this.email});

  final String name;
  final String email;

  factory User.parse(Object? input) => $ack.parse(input);
  static SchemaResult<User> safeParse(Object? input) =>
      $ack.safeParse(input);

  factory User.fromMap(Map<String, Object?> map) => $ack.parse(map);
  factory User.fromJson(Map<String, dynamic> json) => $ack.parse(json);

  Map<String, Object?> toMap() => $ack.encode(this);
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(toMap());
}
```

The generated class stores typed fields. It does not implement `Map` and does
not use a map-backed extension type.

## Serialization

Ack performs parsing and encoding. Generated classes map between Ack's validated
runtime values and stored Dart fields.

This preserves codecs such as:

- `Ack.datetime()` (`String` boundary to `DateTime` runtime);
- `Ack.uri()`;
- `Ack.duration()`;
- enum codecs;
- custom bidirectional codecs.

The generated `fromJson` and `toJson` method shapes are compatible with the
custom-type conventions used by `json_serializable`. Ack does not emit
`@JsonSerializable` and does not call its generator internals.

## Installation

```yaml
dependencies:
  ack: ^1.0.0
  ack_annotations: ^1.0.0

dev_dependencies:
  ack_generator: ^1.0.0
  build_runner: ^2.4.0
```

## Supported declarations

- Top-level schema variables
- Top-level schema getters

`@AckType()` is not supported on classes, instance members, or local variables.

## Planned model shapes

- `Ack.object(...)` -> immutable `final class`
- Primitive and codec roots -> immutable value class
- `Ack.discriminated(...)` -> `sealed class` with `final` branches
- Nested named schemas -> nested generated model fields
- Lists and sets -> unmodifiable typed collections
- Additional properties -> explicit `additionalProperties` map

## Current draft limitations

The rewrite is not yet validated. Before release it still needs:

- migration of all legacy extension-type fixtures;
- normalized graph integration in the analyzer;
- `Ack.lazy` and recursive-model analysis;
- default and one-way-transform capability tracking;
- complete typed map support;
- current analyzer/source_gen dependency validation;
- clean-build `json_serializable` integration fixtures;
- full build, analysis, and runtime test execution.

## Build commands

```bash
dart run build_runner build
dart run build_runner watch
```
