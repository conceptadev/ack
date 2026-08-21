import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void _copyDirectory(Directory source, Directory destination) {
  destination.createSync(recursive: true);
  for (final entity in source.listSync()) {
    final name = p.basename(entity.path);
    if (name == '.dart_tool' || name == 'build' || name.endsWith('.g.dart')) {
      continue;
    }
    final target = p.join(destination.path, name);
    if (entity is Directory) {
      _copyDirectory(entity, Directory(target));
    } else if (entity is File && !name.endsWith('.ack.dart')) {
      entity.copySync(target);
    }
  }
}

Future<ProcessResult> _run(Directory directory, List<String> arguments) {
  return Process.run('dart', arguments, workingDirectory: directory.path);
}

void _expectSuccess(ProcessResult result, String command) {
  expect(
    result.exitCode,
    0,
    reason:
        '$command failed\nSTDOUT:\n${result.stdout}\nSTDERR:\n${result.stderr}',
  );
}

Map<String, String> _generatedContents(Directory directory) => {
  for (final file
      in directory
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.ack.dart')))
    p.relative(file.path, from: directory.path): file.readAsStringSync(),
};

void main() {
  test(
    'example clean-builds, analyzes, tests, and regenerates deterministically',
    () async {
      var projectRoot = Directory.current;
      while (!Directory(
        p.join(projectRoot.path, 'packages', 'ack_generator'),
      ).existsSync()) {
        projectRoot = projectRoot.parent;
      }
      final sourceExample = Directory(p.join(projectRoot.path, 'example'));
      final temporaryRoot = await Directory.systemTemp.createTemp(
        'ack_generator_example_',
      );
      final temporaryExample = Directory(
        p.join(temporaryRoot.path, 'ack_example'),
      );

      try {
        _copyDirectory(sourceExample, temporaryExample);
        File(
          p.join(temporaryExample.path, 'analysis_options.yaml'),
        ).writeAsStringSync('''
analyzer:
  language:
    strict-casts: true
''');
        File(p.join(temporaryExample.path, 'pubspec.yaml')).writeAsStringSync(
          '''
name: ack_example
publish_to: none
environment:
  sdk: '>=3.9.0 <4.0.0'
dependencies:
  ack:
    path: ${p.join(projectRoot.path, 'packages', 'ack')}
  ack_annotations:
    path: ${p.join(projectRoot.path, 'packages', 'ack_annotations')}
dev_dependencies:
  ack_generator:
    path: ${p.join(projectRoot.path, 'packages', 'ack_generator')}
  build_runner: ^2.15.0
  test: ^1.29.0
dependency_overrides:
  ack:
    path: ${p.join(projectRoot.path, 'packages', 'ack')}
  ack_annotations:
    path: ${p.join(projectRoot.path, 'packages', 'ack_annotations')}
''',
        );

        _expectSuccess(
          await _run(temporaryExample, ['pub', 'get']),
          'dart pub get',
        );
        _expectSuccess(
          await _run(temporaryExample, ['run', 'build_runner', 'build']),
          'clean build_runner build',
        );

        final first = _generatedContents(temporaryExample);
        expect(first.keys, {
          'lib/args_getter_example.ack.dart',
          'lib/pet.ack.dart',
          'lib/schema_types_discriminated.ack.dart',
          'lib/schema_types_edge_cases.ack.dart',
          'lib/schema_types_primitives.ack.dart',
          'lib/schema_types_simple.ack.dart',
          'lib/schema_types_transforms.ack.dart',
          'lib/user_with_color.ack.dart',
        });
        for (final content in first.values) {
          expect(content, contains('class '));
          expect(content, isNot(contains('extension type')));
          expect(content, isNot(contains('fromMap')));
          expect(content, isNot(contains('toMap')));
        }

        _expectSuccess(
          await _run(temporaryExample, ['analyze', '--fatal-infos']),
          'dart analyze --fatal-infos',
        );
        _expectSuccess(await _run(temporaryExample, ['test']), 'dart test');
        _expectSuccess(
          await _run(temporaryExample, ['run', 'build_runner', 'build']),
          'second build_runner build',
        );
        expect(_generatedContents(temporaryExample), first);
      } finally {
        temporaryRoot.deleteSync(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
