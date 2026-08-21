# Ack Generator

`ack_generator` turns top-level Ack schemas annotated with `@AckType()` into
immutable Dart model classes.

## Usage

```dart
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

part 'user_schema.ack.dart';
part 'user_schema.g.dart';

@AckType()
final userSchema = Ack.object({
  'name': Ack.string(),
  'email': Ack.string().email(),
});
```

Run `dart run build_runner build`. A declaration ending in `Schema` loses that
suffix, so `userSchema` generates `User`:

```dart
final class User {
  User({required String name, required String email});

  final String name;
  final String email;

  factory User.parse(Object? input);
  static SchemaResult<User> safeParse(Object? input);
  factory User.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  SchemaResult<Map<String, Object?>> safeToJson();

  static final $ack = AckModelAdapter(/* ... */);
}
```

Constructors don't validate immediately. Use `parse` for untrusted input;
`toJson` and `safeToJson` validate a directly constructed model while encoding
it. Generated models don't implement `Map`, and there are no `fromMap` or
`toMap` aliases.

Use `@AckType(name: 'MemberType')` to choose an exact class name. Custom names
must be unchanged UpperCamelCase identifiers.

## Schema support

The generator supports objects, empty objects, scalar and collection roots,
literals, enums, defaults, additional properties, built-in and custom
bidirectional codecs, named nested models, aliases, named `Ack.lazy` recursion,
and same-library discriminated unions. Lists, sets, and maps stored by a model
are copied recursively into unmodifiable collections.

Generation rejects shapes without a useful static, encodable model contract:

- one-way `.transform()` calls; use `.codec()` with an encoder;
- nullable roots;
- `Ack.any()`, `Ack.anyOf()`, and bare `Ack.instance<T>()`;
- anonymous inline object fields and unresolved dynamic schema factories;
- invalid names, generated-member collisions, and cross-library union branches.

Named model references work through direct imports, prefixes, and re-exports.
Nested conversion uses each model's public `$ack` adapter so codec runtime
values aren't parsed twice.

## JSON serialization

Every annotated library declares both parts:

```dart
part 'account.ack.dart';
part 'account.g.dart';
```

Ack owns schema validation, defaults, codecs, union dispatch, and the public
`parse` / `fromJson` / `toJson` methods. `json_serializable` generates the
structural `_$ClassFromJson` / `_$ClassToJson` helpers into the combined JSON
part. Ack-only apps do not add `json_annotation` or `json_serializable`;
`ack_generator` activates that second phase itself.

## Supported declarations

`@AckType()` can annotate top-level schema variables and top-level schema
getters. Classes, instance members, and local variables are rejected.

For design details and migration notes, see
[`docs/architecture/acktype-model-generation.md`](../../docs/architecture/acktype-model-generation.md).
