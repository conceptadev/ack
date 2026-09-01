#!/usr/bin/env dart

import 'dart:io';

import 'src/staging.dart';
import 'src/workspace_packages.dart';

/// Runs `pub publish --dry-run` for every publishable Ack package and requires
/// a clean result.
///
/// `pub` reports packaging problems as warnings, and a warning that reaches
/// pub.dev cannot be withdrawn. The release therefore treats any warning as a
/// failure.
///
/// Usage:
/// `dart scripts/publish_dry_run.dart [package ...]`
///
/// With no arguments the script checks every publishable package.
Future<void> main(List<String> args) async {
  final packages = args.isEmpty ? publishableAckPackages : args;
  final unknown = packages.where(
    (package) => !publishableAckPackages.contains(package),
  );
  if (unknown.isNotEmpty) {
    stderr.writeln(
      'Unknown packages: ${unknown.join(', ')}. '
      'Available packages: ${publishableAckPackages.join(', ')}',
    );
    exitCode = 64;

    return;
  }

  final failures = <String>[];
  for (final package in packages) {
    stdout.writeln('Validating packages/$package ...');
    final failure = await _dryRun(package);
    if (failure != null) failures.add(failure);
  }

  if (failures.isEmpty) {
    stdout.writeln('All ${packages.length} packages publish cleanly.');

    return;
  }

  stderr.writeln('Publish validation failed:');
  for (final failure in failures) {
    stderr.writeln('  - $failure');
  }
  exitCode = 1;
}

/// Returns a failure description, or `null` when [package] is publishable.
Future<String?> _dryRun(String package) async {
  final directory = 'packages/$package';
  // A Flutter package must resolve through the Flutter SDK, so its dry run
  // goes through the `flutter` executable.
  final executable =
      requiresFlutter(File('$directory/pubspec.yaml').readAsStringSync())
      ? 'flutter'
      : 'dart';

  final ProcessResult result;
  try {
    result = await Process.run(executable, [
      'pub',
      'publish',
      '--dry-run',
    ], workingDirectory: directory);
  } on ProcessException catch (error) {
    return '$package: could not run $executable pub publish: ${error.message}';
  }

  final output = '${result.stdout}${result.stderr}';
  stdout.writeln(output);
  if (result.exitCode != 0) {
    return '$package: $executable pub publish exited with ${result.exitCode}';
  }
  if (!output.contains('Package has 0 warnings.')) {
    return '$package: publish validation reported warnings';
  }

  return null;
}
