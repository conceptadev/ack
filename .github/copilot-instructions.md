# Copilot instructions for `btwld/ack`

## Start here first
- Read `/llms.txt` before making code changes. It is the canonical API reference and should be updated in the same PR when public API changes.
- This is a Melos-managed Dart/Flutter monorepo. Primary packages live under `/packages/*`.

## Repository layout
- `packages/ack`: core runtime validation library.
- `packages/ack_annotations`: source annotation for `@AckType()` schema
  generation.
- `packages/ack_generator`: build_runner generator + unit/integration tests.
- `packages/ack_firebase_ai`: Firebase AI schema adapter.
- `packages/ack_json_schema_builder`: JSON Schema adapter.
- `packages/standard_schema`: shared Standard Schema validation and JSON
  Schema converter contracts.
- `example`: sample usage.

## Environment and setup
- Required SDKs: Dart `>=3.8.0 <4.0.0`, Flutter `>=3.16.0` (see `/pubspec.yaml`).
- Use from repo root:
  1. `dart pub get`
  2. `dart run melos bootstrap`
- Optional one-shot setup script: `./setup.sh` (validates the Flutter SDK, bootstraps the workspace, and installs Node tools when npm is available).

## Commands you should run
- Full CI-equivalent local check: `dart run melos run test --no-select`
  - Runs strict analyze (`dart analyze . --fatal-infos`) and package tests.
- Useful targeted commands:
  - `dart run melos run analyze`
  - `dart run melos run test:dart`
  - `dart run melos run test:flutter`
  - `dart run melos run build` (when generator-related code changes)
  - `dart run melos run test:gen` (for generator changes)
  - `dart run melos run validate-jsonschema` (for JSON Schema conformance tooling)

## Change-scope guidance
- Keep changes minimal and package-scoped; do not refactor unrelated files.
- Prefer existing patterns in each package (schema fluent APIs, existing test structure under `test/`).
- Do not hand-edit generated `*.g.dart` files unless the repo pattern for that area explicitly requires it; prefer rerunning build/golden tooling.

## CI and release notes
- CI is defined in `/.github/workflows/ci.yml` and delegates to `btwld/dart-actions/.github/workflows/ci.yml@main` with DCM enabled.
- Conventional Commits are expected for commit messages.
- Publishing/versioning flows are documented in `/PUBLISHING.md` (`dart run melos version`, `dart run melos publish`).

## Errors encountered during onboarding and workarounds
1. **Error:** `melos: command not found` when running checks in a fresh environment.  
   **Workaround:** resolve root dependencies with `dart pub get`, then invoke the workspace-local executable via `dart run melos ...`.
2. **Error:** `dart: command not found` in bare sandbox environments.  
   **Workaround:** install Flutter (which includes Dart), then run `./setup.sh`.
3. **Observed CI state:** workflow run may show `conclusion: action_required` with no jobs for PR contexts awaiting approval/permissions.  
   **Workaround:** have a maintainer approve/enable the run, then re-run CI.
