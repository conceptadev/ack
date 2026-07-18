# Publishing Guide

This document explains how to version and publish the repository's packages to
pub.dev.

## Overview

The repository has two release tracks:

- The Ack package family (`ack`, `ack_annotations`, `ack_generator`,
  `ack_firebase_ai`, and `ack_json_schema_builder`) is versioned together and
  released from `v*` tags.
- `standard_schema` is versioned independently and released from
  `standard_schema-v*` tags. Publish a required `standard_schema` version
  before publishing an Ack release that depends on it.

GitHub Releases and tag workflows provide:

- Centralized release management through GitHub's UI
- Explicit version/changelog control in this repository
- Automated publishing to pub.dev

## Release Process

### 1. Prepare for Release

Before creating a release:

1. Ensure all changes are committed and pushed to the `main` branch
2. Verify that all tests pass by running `dart run melos run test` (include `dart run melos run validate-jsonschema` and `dart run melos run test:gen` for full coverage)
3. Check that the documentation is up to date across the repo and docs site
4. Decide on versions following [Semantic Versioning](https://semver.org/).
   Apply one version consistently to the Ack package family; version
   `standard_schema` independently.
5. Ensure package CHANGELOG entries are finalized before tagging. If you want a link-only entry for a version, you can run `dart scripts/update_release_changelog.dart <version> [tag]` after `dart run melos version`.

### 2. Create an Ack GitHub Release

1. Go to the [Releases page](https://github.com/btwld/ack/releases) in the repository
2. Click "Draft a new release"
3. Create a new tag in the format `v0.2.0` (must start with "v")
4. Add a title, e.g., "Release v0.2.0"
5. Add detailed release notes with a structure like:

```markdown
# Release v0.2.0

This release introduces [brief description of major changes].

## Key Features
- **Feature 1**: Description
- **Feature 2**: Description

## Breaking Changes
- **Feature**: Description of breaking change
  - Detail 1
  - Detail 2

## Improvements
- **Feature**: Description of improvement
  - Detail 1
  - Detail 2

## Bug Fixes
- Fixed [description of bug]
```

> **Note**: You should manually update the `pubspec.yaml` and `CHANGELOG.md` files in each package before creating a tag/release. The release workflow publishes what is already committed.

6. Choose whether this is a pre-release:
   - Check "This is a pre-release" if you're releasing a beta or RC version
   - Pre-releases WILL be published to pub.dev as pre-release versions
   - Only draft releases won't be published to pub.dev

7. Click "Publish release"

For `standard_schema`, use the same process with a tag such as
`standard_schema-v0.0.1`. Its version and changelog are independent of
the Ack package family.

### 3. Automated Steps

When a `v*` or `standard_schema-v*` tag is pushed, the corresponding GitHub
Actions workflow will automatically:

1. Run package tests (Dart/Flutter, depending on package type)
2. Run `dart pub publish --dry-run` for each package
3. Publish each package to pub.dev

The workflow does **not** modify versions or changelogs, and does **not** commit changes back to the repository.

### 4. Verify the Release

After the workflow completes:

1. Check that the packages are available on pub.dev
2. Verify that the version numbers and changelogs are correct
3. Test the published packages in a new project to ensure they work as expected

## Alternative: Manual Versioning

If needed, you can version packages locally from conventional commits:

```bash
# Propose/apply version and changelog updates
dart run melos version

# Non-interactive
dart run melos version --yes

# Push the changes and tags
git push --follow-tags
```

## Manual Publishing

If you need to publish packages manually:

```bash
# Dry-run the independently versioned contract package first.
(cd packages/standard_schema && dart pub publish --dry-run) || exit 1

# Dry-run the synchronized Ack package family.
for pkg in ack ack_annotations ack_generator ack_json_schema_builder ack_firebase_ai; do
  (cd packages/$pkg && dart pub publish --dry-run) || exit 1
done

# Actual publish (no dry-run). Publish standard_schema before a dependent Ack
# release; use Melos package selection or publish from each package directory.
(cd packages/standard_schema && dart pub publish)
dart run melos publish --no-dry-run --yes --scope="ack*"
```

## Troubleshooting

### Release Workflow Fails

If the release workflow fails, check:

1. **Test Failures**: Fix any failing tests or analyze issues
2. **Version Issues**: Check if the version is valid and follows semantic versioning
3. **Permission Issues**: Ensure the GitHub Actions workflow has the necessary permissions
4. **Git Issues**: There might be problems with pushing commits back to the repository

### Manual Publishing Issues

If manual publishing fails:

1. **Authentication**: Ensure you're logged in to pub.dev with `dart pub login`
2. **Version Conflicts**: Check if the version already exists on pub.dev
3. **Dependency Issues**: Verify that all dependencies are correctly specified

## Version Numbering

Every published package follows [Semantic Versioning](https://semver.org/).
The Ack package family shares a version; `standard_schema` does not:

- **Major version (x.0.0)**: Incompatible API changes
- **Minor version (0.x.0)**: Backwards-compatible functionality additions
- **Patch version (0.0.x)**: Backwards-compatible bug fixes

For pre-releases, use formats like `0.2.0-beta.1` or `0.2.0-rc.1`.
