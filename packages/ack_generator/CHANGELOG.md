## 2.0.0

Ack 2.0 is a hard cutoff. The legacy generator is removed with no
compatibility layer, and the JSON phase now writes the ordinary `.g.dart`.

### Removed

* **Breaking:** Remove the `@AckType()` generator, its analyzer, its emitter,
  and the `ack_generator` builder that owned `.g.dart`. There is no frozen
  legacy path and no migration mode.
* **Breaking:** Remove the mixed-graph diagnostics. Legacy and modern models
  can no longer coexist, so a boundary no longer exists to reject.

### Changed

* **Breaking:** Emit the JSON phase as a shared part, so `source_gen`'s
  combining builder writes `file.g.dart`. An annotated library now declares
  `part 'file.ack.dart';` and `part 'file.g.dart';`. Rename every
  `file.ack.g.dart` part directive, and delete the old generated files.
* Ack JSON output and ordinary `json_serializable` output now merge into one
  `.g.dart`. A consumer no longer needs to disable an Ack builder to use
  `json_serializable` in the same library.
* Raise the Dart floor to 3.9 and constrain Analyzer to `>=10.0.0 <11.0.0`.

### Added

* Add `@AckInfer()` schema-first immutable models with parse/JSON/copy/value
  APIs, named recursion, unions, codecs, defaults, nullability, additional
  properties, immutable collections, and cross-library composition.
* Add `@AckModel()` class-first generation with private backing codecs, public
  schema facades, constructor and field inference, unknown-property policies,
  sealed unions, generated mixins, and inferred static `fromJson` aliases.

### Fixed

* Decode constructor-normalized fields through the constructor parameter type.
* Emit strict-lint-compatible equality guards.
* Keep model equality independent of collection wrapper implementations and
  preserve propagated `Error` objects through runtime validation.
* Keep generated class-first `wireSchema` results in their original boundary
  representation when nested models, collections, enums, or codecs decode.
* Distinguish omitted `copyWith` arguments from explicit `null`, so nullable
  fields can be cleared in both schema-first and class-first models.
* Use a dedicated private sentinel type for nullable `copyWith` arguments so a
  consumer's `const Object()` cannot be mistaken for omission.
* Require concrete class-first models and branches plus all stored fields to be
  final, and recursively freeze parsed collections and captured extras.
* Reject unsupported `JsonKey` options and parameter placement, cross-library
  class-first cycles, and direct one-way transforms beneath codecs.

### Migration from 1.x

1. Replace `@AckType()` with `@AckInfer()` for schema-first models, or with
   `@AckModel()` on a hand-written class for class-first models.
2. Replace `part 'file.ack.g.dart';` with `part 'file.g.dart';`.
3. Delete every generated `file.ack.g.dart`, and delete the legacy `file.g.dart`
   that `@AckType()` produced.
4. Replace `*Type` wrapper and `Map` access with the generated model class, and
   use `fromJson` and `toJson` at the JSON boundary.
5. Run `dart run build_runner build --delete-conflicting-outputs`.

## 1.1.0

### Changed

* Use the current source_gen generation error type and keep diagnostic output in
  the build pipeline instead of writing undeclared debug files.
* Remove obsolete exploratory and golden-test utilities.

### Behavior changes

* Reject direct and referenced nullable list element schemas during generation,
  matching the runtime schema contract. *(migration: a previously-succeeding
  `Ack.list(x.nullable())` build now fails; put nullability on the list with
  `Ack.list(x).nullable()`.)*

## 1.0.1

* See [release notes](https://github.com/btwld/ack/releases/tag/v1.0.1) for details.

## 1.0.0

* See [release notes](https://github.com/btwld/ack/releases/tag/v1.0.0) for details.

## 1.0.0-beta.12

### Breaking

* Remove class-based schema generation. `ack_generator` now supports only
  top-level `@AckType()` schema variables and getters.

## 1.0.0-beta.11

* See [release notes](https://github.com/btwld/ack/releases/tag/v1.0.0-beta.11) for details.

## 1.0.0-beta.10

* See [release notes](https://github.com/btwld/ack/releases/tag/v1.0.0-beta.10) for details.

## 1.0.0-beta.9

* See [release notes](https://github.com/btwld/ack/releases/tag/v1.0.0-beta.9) for details.

## 1.0.0-beta.8

* See [release notes](https://github.com/btwld/ack/releases/tag/v1.0.0-beta.8) for details.

## 1.0.0-beta.7

* See [release notes](https://github.com/btwld/ack/releases/tag/v1.0.0-beta.7) for details.

## 1.0.0-beta.6

### Bug Fixes

* **Primitives**: Comprehensive fixes for primitives and correctness (#50).

### Improvements

* **Analyzer**: Refactored field analyzer, model analyzer, and schema AST analyzer for correctness (#50).
* **Builders**: Improved type builder, field builder, and schema builder (#50).
* **Generator**: Centralized null/default handling in generator output (#65).
* **AckType factories**: Generate direct `schema.parseAs(...)` / `schema.safeParseAs(...)` calls and stop emitting `_$ackParse` / `_$ackSafeParse` helpers.

## 1.0.0-beta.5 (2026-01-14)

### Features

* **Doc comments**: Support doc comments for schema descriptions (#61). Field and class doc comments are now used to populate schema descriptions.

### Bug Fixes

* **List types**: Resolve list element types with method chain modifiers (#60). Fixed type resolution for complex list schemas with chained method calls.
* **AckType casts**: Fix @AckType schema ref casts and improve nested schema handling (#59).

### Improvements

* **Dependencies**: Updated `ack`, `ack_annotations`, `meta` and `test` dependencies to latest versions (#56).

## 1.0.0-beta.4 (2025-12-29)

### Bug Fixes

* **Primitives**: Comprehensive fixes for primitive schema generation and correctness.
* **Typed list getters**: Support `Ack.list(schemaRef)` for typed list getters (#47).
* **Field descriptions**: Add field descriptions to generated schema output (#44).
* **Extension types**: Generate extension types for all AckType schemas; skip for nullable AckType schemas.

### Improvements

* **Circular dependency handling**: Improved circular dependency handling and reduced duplication.
* **Analyzer compatibility**: Updated for analyzer >=7.x <9 API changes (#41).
* **Consolidated naming utilities**: Removed duplicate naming utility functions.
* **Documentation**: Fixed stale documentation for extension type generation.

## 1.0.0-beta.3 (2025-10-27)

* See [release notes](https://github.com/btwld/ack/releases/tag/v1.0.0-beta.3) for details.

## 1.0.0-beta.2 (2025-10-09)

* See [release notes](https://github.com/btwld/ack/releases/tag/v1.0.0-beta.2) for details.

## 1.0.0-beta.1 (2025-10-06)

* See [release notes](https://github.com/btwld/ack/releases/tag/v1.0.0-beta.1) for details.
