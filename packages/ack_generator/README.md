# Ack Generator

`ack_generator` supports two directions: `@AckInfer()` turns a top-level Ack
schema into an immutable model, while `@AckModel()` derives an Ack codec schema
from a hand-written class.

Each annotated library declares two parts. `file.ack.dart` holds the generated
model classes and schemas. `file.g.dart` holds the JSON mapping, and it is an
ordinary shared part, so Ack output merges with any `json_serializable` output
in the same library.

## Schema-first usage

```dart
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

part 'user_schema.ack.dart';
part 'user_schema.g.dart';

@AckInfer()
final userSchema = Ack.object({
  'name': Ack.string(),
  'email': Ack.string().email(),
});
```

Run `dart run build_runner build`. A declaration ending in `Schema` loses that
suffix, so `userSchema` generates `User`:

```dart
void main() {
  final user = User.parse({
    'name': 'Ada',
    'email': 'ada@example.com',
  });

  print(user.name);     // String
  print(user.toJson()); // {'name': 'Ada', 'email': 'ada@example.com'}
}
```

Constructors don't validate immediately. Use `parse` for untrusted input;
`toJson` and `safeToJson` validate a directly constructed model while encoding
it. Generated models don't implement `Map`, and there are no `fromMap` or
`toMap` aliases.

Omit `name` when the inferred class name is right. Use
`@AckInfer(name: 'Member')` only when you need an exact custom name. Custom
names must be unchanged UpperCamelCase identifiers.

## Class-first usage

In a class-first library, keep the model in source and apply the generated
mixin:

```dart
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

part 'account.ack.dart';
part 'account.g.dart';

@AckModel()
final class Account with _$AccountAck {
  const Account({required this.name});

  @MinLength(2)
  final String name;

  static final fromJson = AccountSchema.fromJson;
}
```

After generation, the public facade and model JSON methods use the same Ack
codec boundary:

```dart
void main() {
  final account = Account.fromJson({'name': 'Ada'});
  print(account.toJson());
  print(AccountSchema.toJsonSchema());
}
```

## Schema support

The generator supports objects, empty objects, scalar and collection roots,
literals, enums, defaults, additional properties, built-in and custom
bidirectional codecs, named nested models, aliases, named `Ack.lazy` recursion,
and same-library discriminated unions. Lists, sets, and maps stored by a model
generated with `@AckInfer()` are copied recursively into unmodifiable
collections. `@AckModel()` parsing provides the same guarantee, including for
captured extras. Hand-written constructors and collection replacements passed
to `copyWith` remain responsible for their own defensive copies; use
`deepUnmodifiableJsonMap` for dynamic JSON maps. Raw
`Ack.object(..., additionalProperties: true)` schemas preserve extras, while a
class-first model applies its later `unknownProperties` projection. Use
`discard` only for tolerant, read-only consumers and `capture` for round trips.

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
part 'account.g.dart';
```

Ack owns schema validation, defaults, codecs, union dispatch, and the public
`parse` / `fromJson` / `toJson` methods. `json_serializable` generates the
structural `_$ClassFromJson` / `_$ClassToJson` helpers into `file.g.dart`.
Ack-only apps do not add `json_annotation` or `json_serializable`;
`ack_generator` activates that second phase itself.

Ack's JSON phase is a shared part, so a library that also uses ordinary
`json_serializable` needs no extra build configuration. Both generators
contribute to the same `file.g.dart`.

## Supported declarations

`@AckInfer()` can annotate top-level schema variables and top-level schema
getters. Classes, instance members, and local variables are rejected.

`@AckModel()` annotates public, constructable `final class` declarations whose
stored fields are final. Annotated sealed union bases remain supported, and
their concrete branches must also be final. See the
[Model Code Generation guide](https://concepta.dev/documentation/ack/advanced/typesafe-schemas)
for both directions, field inference, sealed unions, passthrough properties,
and build configuration.

For a hand-written `Account`, class-first generation exposes an
`AccountSchema` facade backed by a private `_accountSchema` codec. The facade
provides parsing, safe parsing, encoding, JSON Schema/schema-model export,
typed `schema`, and raw `wireSchema`. Instantiable models apply the generated
`_$AccountAck` mixin, which supplies `toJson`, `copyWith` (omitted means keep;
explicit `null` clears a nullable field), and deep collection-aware equality. Add
`static final fromJson = AccountSchema.fromJson;` when the class should expose
the conventional one-argument entry point. Imported nested models compose as
`prefix.AddressSchema.schema`; `show`/`hide` combinators must expose both the
model and facade.

Class-first wire-name overrides support `@JsonKey(name: 'wire_name')` on the
field. Other `JsonKey` options and constructor-parameter placement fail
generation so schema validation and JSON mapping remain identical.

For design details and migration notes, see the
[model and schema generation architecture](https://github.com/conceptadev/ack/blob/main/docs/architecture/ackinfer-model-generation.md).

## Migrating from Ack 1.x

Ack 2.0 removed the `@AckType()` generator. There is no compatibility layer.

| Ack 1.x | Ack 2.0 |
|---|---|
| `@AckType()` | `@AckInfer()`, or `@AckModel()` on a hand-written class |
| `part 'file.g.dart';` only | `part 'file.ack.dart';` and `part 'file.g.dart';` |
| `part 'file.ack.g.dart';` | `part 'file.g.dart';` |
| `UserType.parse(...)` | `User.parse(...)` or `User.fromJson(...)` |
| Map access and `.args` | Typed fields, `.additionalProperties`, and `toJson()` |

Delete every generated `file.ack.g.dart` and every legacy `file.g.dart` that
`@AckType()` produced, then run
`dart run build_runner build --delete-conflicting-outputs`.
