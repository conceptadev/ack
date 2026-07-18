## 0.0.1

### Added

- Add canonical `StandardTypedV1`, `StandardSchemaV1`, and
  `StandardJsonSchemaV1` names. The dev.0 names remain available as aliases.
- Add `StandardPathSegment` and the opt-in `utils.dart` library with
  `getDotPath` and `StandardSchemaError`.
- Add a complete package example covering validation, transformed output,
  JSON Schema conversion, and dot-path rendering.

### Changed

- Fix the V1 props marker at `version == 1`; constructors no longer accept an
  arbitrary version.
- Make props implementations final and snapshot failure issues, issue paths,
  and schema-error issues into unmodifiable lists.

## 0.0.1-dev.0

Initial dev release reserving the `standard_schema` name on pub.dev.

### Added

- Add the unversioned Standard Schema validation and JSON Schema converter
  contracts, shared props, validation results/issues, converter options, and
  JSON Schema target constants.
- Add a Dart-only combined interface for implementers that expose validation
  and JSON Schema conversion from one `standard` getter.
