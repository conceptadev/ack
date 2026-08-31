## 2.0.0

Ack 2.0 is a hard cutoff. The legacy annotation is removed with no
compatibility layer.

### Removed

* **Breaking:** Remove `@AckType()`. Use `@AckInfer()` for schema-first models
  or `@AckModel()` for class-first models. The generated `*Type` extension
  types, `.args`, `fromMap`, and `toMap` no longer exist.

### Changed

* **Breaking:** An annotated library now declares `part 'file.ack.dart';` and
  the ordinary `part 'file.g.dart';`. Ack 1.x used `file.ack.g.dart` for the
  JSON part.
* Make `AckInfer` and the internal JSON marker annotation classes final.
* Raise the minimum Dart SDK to 3.9.

### Added

* Add `@AckInfer()` for immutable schema-first model generation. Custom names
  are exact.
* Add class-first `@AckModel()`, `@AckField`, constraint annotations,
  `AckUnknownPropertyPolicy`, `unknownProperties`, `captureField`, exact schema
  facade names, and the generated JSON marker used by Ack-owned output.

## 1.1.0

* See [release notes](https://github.com/btwld/ack/releases/tag/v1.1.0) for details.

## 1.0.1

* See [release notes](https://github.com/btwld/ack/releases/tag/v1.0.1) for details.

## 1.0.0

* See [release notes](https://github.com/btwld/ack/releases/tag/v1.0.0) for details.

## 1.0.0-beta.12

### Breaking

* Remove `AckModel`, `AckField`, and decorator annotations. `ack_annotations`
  now exposes only `@AckType()`.

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

### Improvements

* **AckType**: Refined annotation parameters and improved type handling (#50).
* **AckField**: Improved field annotation correctness (#50).
* **Breaking**: `AckField.required` was replaced by `requiredMode` (`AckFieldRequiredMode.auto|required|optional`). Migrate `@AckField(required: true)` to `@AckField(requiredMode: AckFieldRequiredMode.required)` and `required: false` to `requiredMode: AckFieldRequiredMode.optional`.

## 1.0.0-beta.5 (2026-01-14)

### Improvements

* **Documentation**: Fixed broken links and added missing API documentation (#57).
* **Dependencies**: Updated `meta` dependency to latest version (#56).

## 1.0.0-beta.4 (2025-12-29)

* Dependency version bump to align with ack v1.0.0-beta.4.

## 1.0.0-beta.3 (2025-10-27)

* See [release notes](https://github.com/btwld/ack/releases/tag/v1.0.0-beta.3) for details.

## 1.0.0-beta.2 (2025-10-09)

* See [release notes](https://github.com/btwld/ack/releases/tag/v1.0.0-beta.2) for details.

## 1.0.0-beta.1 (2025-10-06)

* See [release notes](https://github.com/btwld/ack/releases/tag/v1.0.0-beta.1) for details.
