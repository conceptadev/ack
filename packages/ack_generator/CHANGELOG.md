## 2.0.0

### Breaking

* Replace map-backed `@AckType()` extension types with immutable Dart model
  classes. Generated names no longer receive a `Type` suffix.
* Generated models no longer implement `Map`, `List`, or scalar interfaces.
  Collection and scalar roots expose a `.value` field.
* Replace passthrough `.args` with `.additionalProperties`, and replace
  generated `fromMap` / `toMap` with `fromJson` / `toJson`.
* Require annotated libraries to declare both `.ack.dart` and `.g.dart` parts.
* Reject one-way transforms and non-string runtime map keys; generated models
  require a bidirectional, statically encodable contract.
* Replace the provisional public lower-camel class-first schema variable with
  an UpperCamelCase facade (`accountSchema` becomes `AccountSchema`). The
  codec backing is private and no compatibility alias is emitted.
* Require instantiable `@AckModel` classes and implicit union branches to apply
  the generated `_$ClassAck` mixin. The mixin supplies `toJson`, `safeToJson`,
  `copyWith` (null means keep the current value), and deep collection-aware
  `==`, `hashCode`, and `toString`.
* Replace class-first `additionalProperties: bool` with
  `AckAdditionalPropertiesMode` and expose `wireSchema` beside typed `schema`.
* Narrow the Analyzer constraint to `>=10.0.0 <11.0.0`.

### Fixed

* Permit optional wire fields backed by required nullable normalization
  parameters, and preserve custom capture fields under `caseStyle` renaming.
* Decode constructor-normalized fields through the constructor parameter type,
  so an omitted optional wire value can reach a nullable parameter even when
  the stored field is non-nullable.
* Emit braced generated equality guards for compatibility with strict lint
  configurations.

### Added

* Generate `parse`, `safeParse`, `fromJson`, `toJson`, `safeToJson`, unchecked
  constructors, and public `$ack` adapters for model classes.
* Add a normalized schema graph foundation for imported, recursive, and
  discriminated model dependencies.
* Generate class-first schema facades with parse, safe parse, encode, safe
  encode, JSON Schema/schema-model export, and a schema composition getter.

### Changed

* Generate dedicated `.ack.dart` source parts and an internal JSON phase that
  delegates structural mapping to `json_serializable`. Annotated libraries
  declare both `.ack.dart` and `.g.dart`. Ack still owns schema validation,
  codecs, defaults, and public parse/JSON methods.
* Reject parse-only transforms and schema shapes without a static model form.
* Support named recursion, cross-file references, custom codecs, additional
  properties, and sealed discriminated model hierarchies.
* Support clean-build schema reuse between class-first and schema-first models,
  including imported models and collection/nullable wrappers. Reject recursive
  class-first graphs with a located diagnostic.

### Migration

* Rename generated `UserType` references to `User` unless `@AckType(name: ...)`
  supplies an exact custom name.
* Use stored fields or `.value` instead of treating models as maps, lists, or
  scalars. Use `.additionalProperties` for passthrough data.
* Replace `fromMap` / `toMap` calls with `fromJson` / `toJson`, add both part
  directives, convert required transforms to codecs, and regenerate outputs.
* Replace class-first `accountSchema` calls with `AccountSchema`; use
  `AccountSchema.schema` for composition. Change lower-camel `schemaName:`
  overrides to exact UpperCamelCase facade names.

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
  top-level `@Ack()` schema variables and getters.

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
* **Ack factories**: Generate direct `schema.parseAs(...)` / `schema.safeParseAs(...)` calls and stop emitting `_$ackParse` / `_$ackSafeParse` helpers.

## 1.0.0-beta.5 (2026-01-14)

### Features

* **Doc comments**: Support doc comments for schema descriptions (#61). Field and class doc comments are now used to populate schema descriptions.

### Bug Fixes

* **List types**: Resolve list element types with method chain modifiers (#60). Fixed type resolution for complex list schemas with chained method calls.
* **Ack casts**: Fix @Ack schema ref casts and improve nested schema handling (#59).

### Improvements

* **Dependencies**: Updated `ack`, `ack_annotations`, `meta` and `test` dependencies to latest versions (#56).

## 1.0.0-beta.4 (2025-12-29)

### Bug Fixes

* **Primitives**: Comprehensive fixes for primitive schema generation and correctness.
* **Typed list getters**: Support `Ack.list(schemaRef)` for typed list getters (#47).
* **Field descriptions**: Add field descriptions to generated schema output (#44).
* **Extension types**: Generate extension types for all Ack schemas; skip for nullable Ack schemas.

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
