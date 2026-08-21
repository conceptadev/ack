# AckType model-class generation

Status: draft implementation for review before validation.

## Goal

Replace the `@AckType()` map-backed extension types with real immutable Dart
classes. The schema remains the single source of truth for validation, defaults,
codecs, and boundary serialization.

```text
JSON boundary
    -> Ack parse
Ack runtime value
    -> generated runtime mapper
immutable model
    -> generated runtime mapper
Ack runtime value
    -> Ack encode
JSON boundary
```

The generated class must not implement `Map<String, Object?>` and must not keep a
backing map as its application data model.

## Public API

Given:

```dart
@AckType()
final userSchema = Ack.object({
  'id': Ack.integer(),
  'name': Ack.string(),
  'createdAt': Ack.datetime(),
});
```

Generate:

```dart
final class User {
  User({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  final int id;
  final String name;
  final DateTime createdAt;

  factory User.parse(Object? input);
  static SchemaResult<User> safeParse(Object? input);
  factory User.fromMap(Map<String, Object?> map);
  factory User.fromJson(Map<String, dynamic> json);
  Map<String, Object?> toMap();
  Map<String, dynamic> toJson();
}
```

`@AckType(name: 'Member')` generates `Member`. The name is exact and no `Type`
suffix is appended.

## JSON serializable relationship

Ack does not emit `@JsonSerializable` and does not call private
`json_serializable` generator APIs.

Ack generates the conventional methods itself:

```dart
factory User.fromJson(Map<String, dynamic> json);
Map<String, dynamic> toJson();
```

This lets source classes processed by `json_serializable` treat an Ack model as a
custom nested type. Actual validation and serialization still run through Ack.

A second hidden generation pass over an Ack-generated class is intentionally not
part of the architecture. Such a pass would require generated source to be
resolved and analyzed again, creating builder-ordering and incremental-build
complexity.

## Build architecture

The generator uses `SharedPartBuilder` with the part ID `ack`.

```text
source.dart
  -> source.ack.g.part       Ack fragment in cache
  -> source.json_serializable.g.part (when present)
  -> source.g.dart           source_gen combining builder
```

The generator emits declarations only. `source_gen` owns the header, `part of`
directive, output combination, and formatting for the target library language
version.

## Runtime adapter

`AckModelAdapter<Boundary, Runtime, Model>` connects the source schema to a
model's generated runtime conversion functions.

The schema is stored as a callback rather than an eager value. This avoids
static initialization cycles and preserves top-level schema getter behavior.

For nested models, generated code calls:

```dart
Address.$ack.fromRuntime(runtimeMap);
Address.$ack.toRuntime(address);
```

It must not call `Address.parse(runtimeMap)`. The parent schema has already
converted boundary values such as strings into runtime values such as
`DateTime`, `Uri`, or custom codec outputs. Parsing again would decode codecs
twice.

## Normalized model graph

The old `FieldInfo` and `ModelInfo` structures combine analyzer state with
extension-type output details. The replacement graph separates analysis from
emission.

A schema identity includes its library URI and declaration name:

```dart
AckSchemaId(
  libraryUri: libraryUri,
  declarationName: declarationName,
)
```

This prevents collisions between equal declaration names in different
libraries.

The normalized graph represents:

- object models;
- value models;
- discriminated unions;
- scalar types;
- external Dart types;
- generated model references;
- lists, sets, and maps;
- input presence separately from nullability;
- bidirectional versus parse-only encoding capability.

The current draft adds this graph next to the existing analyzer. A follow-up
change will make the analyzer produce it directly and remove output-specific
string overrides.

## Recursive dependencies

Generation must not use topological sorting as a recursion strategy.

Resolution uses three states:

```text
unseen -> visiting -> resolved
```

A declaration is registered before its fields are analyzed. A reference to a
`visiting` declaration becomes a graph edge. It does not recursively create a
second copy of the same model.

Dart class declarations can reference each other independent of declaration
order. Output order should remain stable and follow source declaration order.

`Ack.lazy` needs explicit analyzer support before recursive model generation is
considered complete.

## Field semantics

Presence and nullability are different:

| Schema state | Model field | Input behavior |
| --- | --- | --- |
| required, non-nullable | `required T value` | key required, null rejected |
| required, nullable | `required T? value` | key required, null accepted |
| optional, non-nullable | `T? value` | key may be absent, present null rejected |
| optional, nullable | `T? value` | key may be absent or null |
| defaulted | usually `required T value` in constructor | parse supplies default |

A plain `T?` cannot preserve the distinction between an absent key and a key
whose value is explicitly null. The first model release uses canonical output
and does not add hidden presence bits. Exact three-state preservation can be a
separate API feature.

## Collections

Generated fields use concrete typed collections and constructor inputs are
copied to unmodifiable collections.

```dart
final List<Address> addresses;
final Set<String> tags;
final Map<String, Permission> permissions;
```

Nested model elements convert through their `$ack` adapters.

## Additional properties

Schemas that allow additional properties generate:

```dart
final Map<String, Object?> additionalProperties;
```

Encoding merges additional properties first and declared fields second, so an
extra property cannot replace a declared property.

## One-way transforms

`transform()` is parse-only. `codec()` is bidirectional.

The normalized graph tracks encode capability. Full model generation should
produce a build error when any field is parse-only:

```text
Cannot generate toJson for User because field "color" uses a one-way transform.
Replace transform() with codec().
```

The current draft emitter does not yet propagate this capability from the AST.
It is a required validation item before merge.

## Discriminated unions

Generate a sealed hierarchy:

```dart
sealed class Pet {
  const Pet();
}

final class Cat extends Pet {
  Cat({required this.lives});
  final int lives;
  String get kind => 'cat';
}
```

Preserve current discriminator checks:

- branches are named and statically resolvable;
- branches belong to the same library;
- discriminator literals and enums are compatible;
- broad or conflicting discriminator schemas fail generation;
- a branch belongs to only one union base;
- branch parse operations validate through the union's effective branch.

## Current draft scope

This branch contains the main architecture for review:

- shared-part builder configuration;
- `AckModelAdapter` runtime bridge;
- immutable object and value class emitter;
- sealed discriminated-class emitter;
- normalized graph types and recursive-resolution states;
- annotation contract and naming change.

It is intentionally not represented as validated. Remaining work includes:

- migrate all extension-type golden and integration tests;
- make the analyzer produce the normalized graph directly;
- add `Ack.lazy` analysis;
- track defaults and encode capability;
- complete map value typing;
- validate import and generated-name collisions;
- add clean-build `json_serializable` fixtures;
- run formatting, build, analysis, and runtime tests;
- remove legacy extension-only documentation and examples;
- review dependency ranges for the current analyzer/source_gen stack.

## Validation checklist

Before this draft can leave draft status:

```text
[ ] dart pub get
[ ] dart format --output=none --set-exit-if-changed .
[ ] dart analyze --fatal-infos
[ ] dart test
[ ] dart run build_runner clean
[ ] dart run build_runner build --delete-conflicting-outputs
[ ] example package builds from no generated files
[ ] nested DateTime/Uri/Duration round trips
[ ] custom codec round trips
[ ] direct, prefixed, and re-exported model references
[ ] self-recursive and mutually-recursive models
[ ] discriminated branch parse and encode
[ ] additional-property collision behavior
[ ] optional, nullable, and defaulted field behavior
[ ] json_serializable builder coexistence fixture
[ ] json_serializable custom nested-type fixture
```
