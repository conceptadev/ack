#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

import 'src/workspace_packages.dart';

const availablePackages = publishablePackages;
const dartApiToolVersion = '0.23.0';

Future<void> main(List<String> args) async {
  // Parse arguments
  String? packageName;
  String? version;

  if (args.isNotEmpty) {
    // Check if first argument is a version (starts with v or is a number)
    final firstArg = args[0];
    if (firstArg.startsWith('v') || RegExp(r'^\d+\.\d+').hasMatch(firstArg)) {
      // A shared version applies to the synchronized Ack package family.
      version = firstArg;
    } else if (availablePackages.contains(firstArg)) {
      // First argument is a package name
      packageName = firstArg;
      if (args.length > 1) {
        version = args[1];
      }
    } else {
      print(
        '❌ Invalid package name. Available packages: ${availablePackages.join(', ')}',
      );
      printUsage();
      exit(1);
    }
  }

  // If no version provided, get latest from pub.dev
  if (version == null) {
    if (packageName != null) {
      version = await getLatestVersion(packageName);
    } else {
      print('❌ Please specify a version when checking the Ack package family');
      printUsage();
      exit(1);
    }
  }

  // Remove 'v' prefix if present
  final cleanVersion = version.startsWith('v') ? version.substring(1) : version;

  print('🚀 API Compatibility Check vs $version');

  // Activate dart_apitool
  final activated = await runCommand('dart', [
    'pub',
    'global',
    'activate',
    'dart_apitool',
    dartApiToolVersion,
  ]);
  if (!activated) {
    stderr.writeln('❌ Unable to activate dart_apitool.');
    exitCode = 1;
    return;
  }

  // Check packages
  final packagesToCheck = packageName != null
      ? [packageName]
      : publishableAckPackages;
  final reports = <String>[];
  var hasFailures = false;

  for (final pkg in packagesToCheck) {
    if (!await checkPackage(pkg, cleanVersion, version, reports)) {
      hasFailures = true;
    }
  }

  // Print summary
  print('');
  print(
    hasFailures
        ? '❌ API compatibility check found changes or errors.'
        : '🎯 API compatibility check completed!',
  );
  print('📂 Reports saved in project root:');
  for (final report in reports) {
    print('   • $report');
  }
  if (hasFailures) exitCode = 1;
}

Future<String> getLatestVersion(String packageName) async {
  try {
    final result = await Process.run('curl', [
      '-s',
      'https://pub.dev/api/packages/$packageName',
    ]);

    if (result.exitCode == 0) {
      final decoded = jsonDecode(result.stdout);
      if (decoded is Map) {
        final latest = decoded['latest'];
        if (latest is Map) {
          final latestVersion = latest['version'];
          if (latestVersion is String) return latestVersion;
        }
      }
    }
  } catch (e) {
    stderr.writeln('Could not fetch the latest $packageName version: $e');
  }

  stderr.writeln(
    'Could not fetch the latest version for $packageName; specify one explicitly.',
  );
  exit(1);
}

Future<bool> checkPackage(
  String packageName,
  String cleanVersion,
  String displayVersion,
  List<String> reports,
) async {
  print('📦 Checking $packageName package...');

  final reportFile = 'api-compat-$packageName-vs-$displayVersion.md';
  final report = File(reportFile);
  try {
    if (report.existsSync()) report.deleteSync();
  } on FileSystemException catch (error) {
    stderr.writeln('❌ $packageName: Could not replace $reportFile: $error');
    return false;
  }

  final ProcessResult result;
  try {
    result = await Process.run('dart', [
      'pub',
      'global',
      'run',
      'dart_apitool:main',
      'diff',
      '--old',
      'pub://$packageName/$cleanVersion',
      '--new',
      './packages/$packageName',
      '--report-format',
      'markdown',
      '--report-file-path',
      reportFile,
      '--ignore-prerelease',
    ]);
  } on ProcessException catch (error) {
    stderr.writeln('❌ $packageName: Could not run dart_apitool: $error');
    return false;
  }

  if (result.exitCode == 0) {
    print('✅ $packageName: API check completed');
  } else {
    stderr.writeln('❌ $packageName: API changes detected or check failed');
    _writeProcessStderr(result);
  }

  final reportExists = report.existsSync();
  if (reportExists) {
    reports.add(reportFile);
    print('📄 Report saved: $reportFile');
  } else if (result.exitCode == 0) {
    stderr.writeln('❌ $packageName: dart_apitool did not create $reportFile');
  }
  return result.exitCode == 0 && reportExists;
}

Future<bool> runCommand(String command, List<String> args) async {
  try {
    final result = await Process.run(command, args);
    if (result.exitCode == 0) return true;

    stderr.writeln('Error running $command ${args.join(' ')}');
    _writeProcessStderr(result);
  } on ProcessException catch (error) {
    stderr.writeln('Error running $command ${args.join(' ')}: $error');
  }
  return false;
}

void _writeProcessStderr(ProcessResult result) {
  if ((result.stderr as String).isNotEmpty) {
    stderr.writeln(result.stderr);
  }
}

void printUsage() {
  print('');
  print('Usage: dart scripts/api_check.dart [PACKAGE] [VERSION]');
  print('');
  print('Arguments:');
  print('  PACKAGE  Package to check (${availablePackages.join('|')})');
  print('           If not provided, checks the Ack release-family packages');
  print('  VERSION  Version to compare against (e.g., v0.2.0 or 0.2.0)');
  print(
    '           If not provided with single package, uses latest from pub.dev',
  );
  print('');
  print('Examples:');
  print(
    '  dart scripts/api_check.dart ack                    # Check ack against latest',
  );
  print(
    '  dart scripts/api_check.dart ack v0.2.0            # Check ack against v0.2.0',
  );
  print(
    '  dart scripts/api_check.dart v0.2.0                # Check the Ack family against v0.2.0',
  );
  print('');
  print('Melos usage:');
  print('  dart run melos run api-check -- ack v0.2.0');
  print('  dart run melos run api-check -- v0.2.0');
}
