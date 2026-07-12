## Unreleased

### Fixed

* Keep `safeParse` non-throwing when refinements or constraints throw exceptions.
* Bound direct, indirect, wrapper-mediated, and fluent-copy lazy-schema alias
  recursion (previously unbounded and prone to stack overflow).
* Snapshot factory collections so a caller mutating the passed list or map can no
  longer corrupt a constructed schema.
* Correct behavior-based schema and deep-collection equality.

### Behavior changes

No public API changed (verified with `dart_apitool` against 1.0.1); the following
now reject inputs that previously passed or misbehaved silently.

* Validate numeric `multipleOf`, IPv6, and RFC 3339 date-time values strictly.
  Announced leap seconds are preserved by `Ack.string().datetime()` but rejected
  by `Ack.datetime()`, where Dart cannot represent them. *(migration: some
  previously-accepted strings and numbers now fail validation.)*
* Reject invalid constraint configuration at construction — negative
  lengths/item counts, non-finite numeric bounds, `min > max` ranges,
  `multipleOf <= 0`, empty unions, empty or duplicate enum inputs, and unions
  that can yield nullable list items — all throw `ArgumentError`. *(migration:
  fix the schema definition; put nullability on the list via
  `Ack.list(item).nullable()`.)*
* `toJsonSchema()` merges conflicting duplicate keywords into `allOf` and emits
  `min/maxItems` and `min/maxProperties` for exact counts. *(migration: refresh
  snapshot or golden tests of exported schemas.)*
* `parse()` throws `AckException` — instead of the raw callback error — when a
  constraint or refinement throws.

## 1.0.1

* See [release notes](https://github.com/btwld/ack/releases/tag/v1.0.1) for details.

## 1.0.0

* See [release notes](https://github.com/btwld/ack/releases/tag/v1.0.0) for details.

## 1.0.0-beta.12

### Breaking Changes

* `DoubleSchema` and `NumberSchema` now reject non-finite values (`NaN`,
  `Infinity`, `-Infinity`) during runtime validation by default, aligning
  numeric schemas with JSON-safe values.
* Remove the retired JSON Schema DTO converter APIs.
* Replace the interim JSON Schema model kind API with sealed
  `AckSchemaModel` variants and canonical `AckSchema.toSchemaModel()`
  adapter conversion.

### Added

* `Ack.enumCodec<T extends Enum>(List<T> values)` returns a
  `CodecSchema<String, T>` wrapping `EnumSchema<T>`. Use this when downstream
  code expects every value-shape to be a `CodecSchema` (e.g. a registry of
  codecs). Decode/encode are identity since `EnumSchema` already maps between
  `T` and the enum's `.name`.
* `NumberSchemaExtensions` adds fluent numeric constraints to `Ack.number()`:
  `.min`, `.max`, `.greaterThan`, `.lessThan`, `.positive`, `.negative`, and
  `.multipleOf`.

### Changed

* Project discriminated schemas through union-owned discriminator branches.
* Preserve defaults, const values, extension keywords, transformed metadata,
  composition, and JSON Schema constraints through the schema model boundary.

### Migration

* Re-run tests for code paths that parse or encode `double`/`num` values. If a
  boundary must accept `NaN` or infinities, model that value outside the JSON
  numeric schema path before validation.

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

### Features

* **Discriminated unions**: Enforce Map-returning child schemas in discriminated unions (#67).
* **Schema mapping API**: Add `AckSchema.parseAs` and `AckSchema.safeParseAs` for validated-value mapping with consistent `SchemaTransformError` handling.

### Improvements

* **Schemas**: Centralize null/default handling and extract ObjectSchema helpers (#65).

### Bug Fixes

* **Schemas**: Fixes to schema correctness including transformed schema defaults and list unique items constraint (#50).

## 1.0.0-beta.5 (2026-01-14)

### Features

* **Equality**: Implement value-based equality for schemas and constraints (#63). All schema and constraint classes now properly implement `==` and `hashCode` for structural comparison.

### Improvements

* **Dependencies**: Updated `meta` and `test` dependencies to latest versions (#56).

## 1.0.0-beta.4 (2025-12-29)

### Breaking Changes

* **Format metadata**: Reduced built-in format guidance to 7 core formats (`email`, `uri`, `uuid`, `date`, `dateTime`, `ipv4`, `ipv6`). Custom format strings are still supported via the `format` property.
* **`withDescription` deprecated**: Use `describe()` instead for setting schema descriptions.

### Bug Fixes

* **JSON Schema output**: Now correctly adds null branch to `anyOf`/`oneOf` compositions when `nullable: true`, producing valid JSON Schema Draft-07 format.

### Improvements

* **DRY refactoring**: Consolidated duplicate primitive schema parsers into one.
* **Hardened schema type handling**: Improved map validation and schema type handling.
* **Consolidated JSON schema utilities**: Reduced duplication across JSON schema utilities.

## 1.0.0-beta.3 (2025-10-27)

* See [release notes](https://github.com/btwld/ack/releases/tag/v1.0.0-beta.3) for details.

## 1.0.0-beta.2 (2025-10-09)

* See [release notes](https://github.com/btwld/ack/releases/tag/v1.0.0-beta.2) for details.

## 1.0.0-beta.1 (2025-10-06)

* See [release notes](https://github.com/btwld/ack/releases/tag/v1.0.0-beta.1) for details.
