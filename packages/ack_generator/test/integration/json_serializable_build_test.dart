import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

Directory _projectRoot() {
  var projectRoot = Directory.current;
  while (!Directory(
    p.join(projectRoot.path, 'packages', 'ack_generator'),
  ).existsSync()) {
    projectRoot = projectRoot.parent;
  }
  return projectRoot;
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

int _helperPairCount(String source, String className) {
  return RegExp('_\\\$${className}FromJson').allMatches(source).length;
}

void main() {
  test(
    'ack_generator alone generates json_serializable Ack helpers',
    () async {
      final projectRoot = _projectRoot();
      final temporary = await Directory.systemTemp.createTemp(
        'ack_json_ack_only_',
      );
      try {
        Directory(p.join(temporary.path, 'lib')).createSync();
        File(p.join(temporary.path, 'pubspec.yaml')).writeAsStringSync('''
name: ack_json_ack_only
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
dependency_overrides:
  ack:
    path: ${p.join(projectRoot.path, 'packages', 'ack')}
  ack_annotations:
    path: ${p.join(projectRoot.path, 'packages', 'ack_annotations')}
''');
        File(p.join(temporary.path, 'lib', 'user.dart')).writeAsStringSync(r'''
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

part 'user.ack.dart';
part 'user.g.dart';

@AckType()
final userSchema = Ack.object({
  'name': Ack.string(),
  'createdAt': Ack.datetime(),
});
''');

        _expectSuccess(await _run(temporary, ['pub', 'get']), 'dart pub get');
        _expectSuccess(
          await _run(temporary, ['run', 'build_runner', 'build']),
          'clean build_runner build',
        );

        final ackPart = File(
          p.join(temporary.path, 'lib', 'user.ack.dart'),
        ).readAsStringSync();
        final jsonPart = File(
          p.join(temporary.path, 'lib', 'user.g.dart'),
        ).readAsStringSync();

        expect(ackPart, contains('@AckType.jsonSerializable'));
        expect(ackPart, contains(r'_$UserFromJson'));
        expect(ackPart, contains('_ackFromRuntimeCreatedAt'));
        expect(jsonPart, contains('JsonSerializableGenerator'));
        expect(jsonPart, contains('User._ackFromRuntimeName(json[\'name\'])'));
        expect(
          jsonPart,
          contains('User._ackFromRuntimeCreatedAt(json[\'createdAt\'])'),
        );
        expect(jsonPart, contains('User._ackToRuntimeName(instance.name)'));
        expect(_helperPairCount(jsonPart, 'User'), 1);
        expect(jsonPart, isNot(contains("value['name']")));
      } finally {
        temporary.deleteSync(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );

  test(
    'ordinary json_serializable coexists without duplicate Ack helpers',
    () async {
      final projectRoot = _projectRoot();
      final temporary = await Directory.systemTemp.createTemp(
        'ack_json_coexist_',
      );
      try {
        Directory(p.join(temporary.path, 'lib')).createSync();
        File(p.join(temporary.path, 'pubspec.yaml')).writeAsStringSync('''
name: ack_json_coexist
publish_to: none
environment:
  sdk: '>=3.9.0 <4.0.0'
dependencies:
  ack:
    path: ${p.join(projectRoot.path, 'packages', 'ack')}
  ack_annotations:
    path: ${p.join(projectRoot.path, 'packages', 'ack_annotations')}
  json_annotation: ^4.12.0
dev_dependencies:
  ack_generator:
    path: ${p.join(projectRoot.path, 'packages', 'ack_generator')}
  build_runner: ^2.15.0
  json_serializable: ^6.14.1
dependency_overrides:
  ack:
    path: ${p.join(projectRoot.path, 'packages', 'ack')}
  ack_annotations:
    path: ${p.join(projectRoot.path, 'packages', 'ack_annotations')}
''');
        File(p.join(temporary.path, 'build.yaml')).writeAsStringSync('''
targets:
  \$default:
    builders:
      json_serializable:
        options:
          include_if_null: true
''');
        File(p.join(temporary.path, 'lib', 'same.dart')).writeAsStringSync(r'''
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';
import 'package:json_annotation/json_annotation.dart';

part 'same.ack.dart';
part 'same.g.dart';

@AckType()
final userSchema = Ack.object({
  'name': Ack.string(),
  'nickname': Ack.string().optional(),
});

@JsonSerializable()
final class SameEnvelope {
  const SameEnvelope({required this.count, this.label});
  factory SameEnvelope.fromJson(Map<String, dynamic> json) =>
      _$SameEnvelopeFromJson(json);
  final int count;
  final String? label;
  Map<String, dynamic> toJson() => _$SameEnvelopeToJson(this);
}
''');

        _expectSuccess(await _run(temporary, ['pub', 'get']), 'dart pub get');
        _expectSuccess(
          await _run(temporary, ['run', 'build_runner', 'build']),
          'build_runner build',
        );
        _expectSuccess(
          await _run(temporary, ['analyze', '--fatal-infos']),
          'dart analyze --fatal-infos',
        );

        final combined = File(
          p.join(temporary.path, 'lib', 'same.g.dart'),
        ).readAsStringSync();
        expect(_helperPairCount(combined, 'User'), 1);
        expect(_helperPairCount(combined, 'SameEnvelope'), 1);
        expect(combined, contains('User._ackFromRuntimeName(json[\'name\'])'));
        expect(combined, contains('JsonSerializableGenerator'));
        expect(
          combined.contains("'label': instance.label") ||
              combined.contains("'label': ?instance.label"),
          isTrue,
        );
      } finally {
        temporary.deleteSync(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
