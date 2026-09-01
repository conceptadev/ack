#!/usr/bin/env dart

import 'dart:io';

import 'src/release_changelog.dart';
import 'src/staging.dart';
import 'src/workspace_packages.dart';

/// Verifies that a release tag may publish the packages in this checkout.
///
/// A tag is the only trigger of `.github/workflows/release.yml`, so the tag
/// itself must prove three things before any upload:
///
/// 1. Its commit is reachable from `main`, which keeps unreviewed commits out
///    of a release.
/// 2. Every publishable package declares exactly the tagged version.
/// 3. Every publishable changelog documents that version.
///
/// Usage:
/// `dart scripts/verify_release_tag.dart <tag> [options]`
///
/// Options:
///   `--main-ref=<ref>`  Ref that must contain the tag. Defaults to
///                     `origin/main`.
///   `--commit=<sha>`    Commit that the tag points at. Defaults to the
///                     commit that `<tag>` resolves to in this checkout.
///   --skip-ancestry   Skip the reachability check. Use it only when checking
///                     a version before the tag exists.
void main(List<String> args) {
  final options = _Options.parse(args);
  if (options == null) {
    stderr.writeln(
      'Usage: dart scripts/verify_release_tag.dart <tag> '
      '[--main-ref=<ref>] [--commit=<sha>] [--skip-ancestry]',
    );
    exitCode = 64;

    return;
  }

  final parsed = _versionFromTag(options.tag);
  final failures = <String>[
    ...?parsed.failure,
    ...?_checkPackages(parsed.version),
    if (!options.skipAncestry) ..._checkAncestry(options),
  ];

  if (failures.isEmpty) {
    stdout.writeln('${options.tag} is releasable.');

    return;
  }

  stderr.writeln('${options.tag} is not releasable:');
  for (final failure in failures) {
    stderr.writeln('  - $failure');
  }
  exitCode = 1;
}

/// Splits `v1.2.0` into its version, or reports why the tag is unusable.
({String? version, List<String>? failure}) _versionFromTag(String tag) {
  final match = RegExp(
    r'^v(\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?)$',
  ).firstMatch(tag);
  if (match == null) {
    return (
      version: null,
      failure: ['tag "$tag" is not a `v<major>.<minor>.<patch>` release tag'],
    );
  }

  return (version: match.group(1)!, failure: null);
}

/// Checks that every publishable package and changelog states [version].
List<String>? _checkPackages(String? version) {
  if (version == null) return null;

  final failures = <String>[];
  for (final package in publishableAckPackages) {
    final pubspecPath = 'packages/$package/pubspec.yaml';
    final pubspec = File(pubspecPath);
    if (!pubspec.existsSync()) {
      failures.add('$pubspecPath is missing');
      continue;
    }

    final declared = readPubspecVersion(pubspec.readAsStringSync());
    if (declared != version) {
      failures.add('$pubspecPath declares "$declared" instead of "$version"');
    }

    final changelogPath = 'packages/$package/CHANGELOG.md';
    final changelog = File(changelogPath);
    if (!changelog.existsSync()) {
      failures.add('$changelogPath is missing');
      continue;
    }

    if (!hasVersionHeading(changelog.readAsStringSync(), version: version)) {
      failures.add('$changelogPath has no "## $version" heading');
    }
  }

  return failures;
}

/// Checks that the tagged commit is reachable from the release branch.
List<String> _checkAncestry(_Options options) {
  final commit = options.commit ?? _revParse('${options.tag}^{commit}');
  if (commit == null) {
    return ['tag "${options.tag}" does not resolve to a commit'];
  }

  final mainCommit = _revParse('${options.mainRef}^{commit}');
  if (mainCommit == null) {
    return [
      'ref "${options.mainRef}" is not available; '
          'fetch it before verifying the tag',
    ];
  }

  final ancestry = Process.runSync('git', [
    'merge-base',
    '--is-ancestor',
    commit,
    mainCommit,
  ]);
  if (ancestry.exitCode == 0) return const [];

  return [
    'commit $commit is not reachable from ${options.mainRef} ($mainCommit)',
  ];
}

String? _revParse(String revision) {
  final result = Process.runSync('git', ['rev-parse', '--verify', revision]);
  if (result.exitCode != 0) return null;

  return (result.stdout as String).trim();
}

class _Options {
  const _Options({
    required this.tag,
    required this.mainRef,
    required this.commit,
    required this.skipAncestry,
  });

  final String tag;
  final String mainRef;
  final String? commit;
  final bool skipAncestry;

  static _Options? parse(List<String> args) {
    final positional = <String>[];
    var mainRef = 'origin/main';
    String? commit;
    var skipAncestry = false;

    for (final arg in args) {
      if (arg == '--skip-ancestry') {
        skipAncestry = true;
      } else if (arg.startsWith('--main-ref=')) {
        mainRef = arg.substring('--main-ref='.length);
      } else if (arg.startsWith('--commit=')) {
        commit = arg.substring('--commit='.length);
      } else if (arg.startsWith('--')) {
        return null;
      } else {
        positional.add(arg);
      }
    }
    if (positional.length != 1) return null;

    return _Options(
      tag: positional.single,
      mainRef: mainRef,
      commit: commit,
      skipAncestry: skipAncestry,
    );
  }
}
