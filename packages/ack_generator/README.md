# Ack Generator

`ack_generator` supports two modern directions: `@AckInfer()` turns a top-level Ack
schema into an immutable model, while `@AckModel()` derives an Ack codec schema
from a hand-written class. It also retains the deprecated Ack 1.1 `@AckType()`
generator unchanged.

## Usage

```dart
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

part 'user_schema.ack.dart';
part 'user_schema.ack.g.dart';

@AckInfer()
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
  User copyWith({String? name, String? email});

  static final $ack = AckModelAdapter(/* ... */);
}
```

Constructors don't validate immediately. Use `parse` for untrusted input;
`toJson` and `safeToJson` validate a directly constructed model while encoding
it. Generated models don't implement `Map`, and there are no `fromMap` or
`toMap` aliases.

Use `@AckInfer(name: 'MemberType')` to choose an exact class name. Custom names
must be unchanged UpperCamelCase identifiers.

## Schema support

The generator supports objects, empty objects, scalar and collection roots,
literals, enums, defaults, additional properties, built-in and custom
bidirectional codecs, named nested models, aliases, named `Ack.lazy` recursion,
and same-library discriminated unions. Lists, sets, and maps stored by a model
are copied recursively into unmodifiable collections.

Generation rejects shapes without a useful static, encodable model contract:

- one-way `.transform()` calls, including `.trim()`, `.toLowerCase()`, and
  `.toUpperCase()`; use `.codec()` with an encoder;
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
part 'account.ack.g.dart';
```

Ack owns schema validation, defaults, codecs, union dispatch, and the public
`parse` / `fromJson` / `toJson` methods. `json_serializable` generates the
structural `_$ClassFromJson` / `_$ClassToJson` helpers into the Ack JSON
part. Ack-only apps do not add `json_annotation` or `json_serializable`;
`ack_generator` activates that second phase itself.

When a modern-only target also uses an ordinary source-gen builder that owns
`.g.dart`, disable the unused legacy builder in that target so it remains the
sole `.g.dart` owner:

```yaml
targets:
  $default:
    builders:
      ack_generator:ack_generator:
        enabled: false
```

## Supported declarations

`@AckInfer()` can annotate top-level schema variables and top-level schema
getters. Classes, instance members, and local variables are rejected.

`@AckModel()` annotates public, constructable classes. See the
[Model Code Generation guide](../../docs/core-concepts/typesafe-schemas.mdx)
for both directions, field inference, sealed unions, passthrough properties,
and build configuration.

For a hand-written `Account`, class-first generation exposes an
`AccountSchema` facade backed by a private `_accountSchema` codec. The facade
provides parsing, safe parsing, encoding, JSON Schema/schema-model export,
typed `schema`, and raw `wireSchema`. Instantiable models apply the generated
`_$AccountAck` mixin, which supplies `toJson`, `copyWith` (null means keep the
current value), and deep collection-aware equality. Add
`static final fromJson = AccountSchema.fromJson;` when the class should expose
the conventional one-argument entry point. Imported nested models compose as
`prefix.AddressSchema.schema`; `show`/`hide` combinators must expose both the
model and facade.

For design details and migration notes, see
[`docs/architecture/ackinfer-model-generation.md`](../../docs/architecture/ackinfer-model-generation.md).

## Deprecated AckType compatibility

An unchanged Ack 1.1 declaration still uses `part 'file.g.dart';` and generates
the same `*Type`, `.args`, Map, `parse`, and `safeParse` APIs. `AckType` is frozen
until its removal in Ack 2.0. New connected model graphs must use `AckInfer` or
`AckModel`; nested references between legacy and modern graphs are rejected
with a migration diagnostic.

| Legacy | Modern opt-in |
|---|---|
| `@AckType()` | `@AckInfer()` |
| `file.g.dart` | `file.ack.dart` + `file.ack.g.dart` |
| `UserType.parse(...)` | `User.parse(...)` or `User.fromJson(...)` |
| Map access and `.args` | Typed fields, `.additionalProperties`, and `toJson()` |
