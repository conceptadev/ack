import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'activation failures stop API checks with a non-zero exit code',
    () async {
      final fakeBin = Directory.systemTemp.createTempSync('ack-api-check-');
      addTearDown(() => fakeBin.deleteSync(recursive: true));

      _writeExecutable(fakeBin, 'dart', '#!/bin/sh\nexit 23\n');

      final result = await Process.run(
        Platform.resolvedExecutable,
        ['scripts/api_check.dart', 'ack', '1.0.0'],
        environment: {
          ...Platform.environment,
          'PATH': '${fakeBin.path}:/usr/bin:/bin',
        },
      );

      expect(result.exitCode, 1);
      expect(result.stderr, contains('Unable to activate dart_apitool'));
      expect(result.stdout, isNot(contains('Checking ack package')));
    },
    skip: Platform.isWindows ? 'Uses POSIX test executables.' : false,
  );

  test(
    'stale reports do not satisfy the current API check',
    () async {
      final fakeBin = Directory.systemTemp.createTempSync('ack-api-check-');
      final workingDirectory = Directory.systemTemp.createTempSync(
        'ack-api-report-',
      );
      addTearDown(() => fakeBin.deleteSync(recursive: true));
      addTearDown(() => workingDirectory.deleteSync(recursive: true));

      _writeExecutable(fakeBin, 'dart', '#!/bin/sh\nexit 0\n');
      final staleReport = File(
        '${workingDirectory.path}/api-compat-ack-vs-1.0.0.md',
      )..writeAsStringSync('stale report');
      final scriptPath = File('scripts/api_check.dart').absolute.path;

      final result = await Process.run(
        Platform.resolvedExecutable,
        [scriptPath, 'ack', '1.0.0'],
        workingDirectory: workingDirectory.path,
        environment: {
          ...Platform.environment,
          'PATH': '${fakeBin.path}:/usr/bin:/bin',
        },
      );

      expect(result.exitCode, 1);
      expect(result.stderr, contains('did not create'));
      expect(staleReport.existsSync(), isFalse);
    },
    skip: Platform.isWindows ? 'Uses POSIX test executables.' : false,
  );
}

void _writeExecutable(Directory directory, String name, String contents) {
  final file = File('${directory.path}/$name')..writeAsStringSync(contents);
  final chmod = Process.runSync('chmod', ['+x', file.path]);
  expect(chmod.exitCode, 0);
}
