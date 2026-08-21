import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test(
    'json_serializable resolves same-file and cross-file generated Ack models',
    () async {
      var projectRoot = Directory.current;
      while (!Directory(
        p.join(projectRoot.path, 'packages', 'ack_generator'),
      ).existsSync()) {
        projectRoot = projectRoot.parent;
      }
      final temporary = await Directory.systemTemp.createTemp(
        'ack_json_build_',
      );
      try {
        Directory(p.join(temporary.path, 'lib')).createSync();
        File(p.join(temporary.path, 'pubspec.yaml')).writeAsStringSync('''
name: ack_json_build
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
        File(p.join(temporary.path, 'lib', 'same.dart')).writeAsStringSync(r'''
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';
import 'package:json_annotation/json_annotation.dart';

part 'same.ack.dart';
part 'same.g.dart';

@AckType()
final userSchema = Ack.object({'name': Ack.string()});

@JsonSerializable(explicitToJson: true)
final class SameEnvelope {
  const SameEnvelope(this.user);
  factory SameEnvelope.fromJson(Map<String, dynamic> json) =>
      _$SameEnvelopeFromJson(json);
  final User user;
  Map<String, dynamic> toJson() => _$SameEnvelopeToJson(this);
}
''');
        File(p.join(temporary.path, 'lib', 'address.dart')).writeAsStringSync(
          r'''
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

part 'address.ack.dart';

@AckType()
final addressSchema = Ack.object({'city': Ack.string()});
''',
        );
        File(p.join(temporary.path, 'lib', 'cross.dart')).writeAsStringSync(r'''
import 'package:json_annotation/json_annotation.dart';

import 'address.dart';

part 'cross.g.dart';

@JsonSerializable(explicitToJson: true)
final class CrossEnvelope {
  const CrossEnvelope(this.address);
  factory CrossEnvelope.fromJson(Map<String, dynamic> json) =>
      _$CrossEnvelopeFromJson(json);
  final Address address;
  Map<String, dynamic> toJson() => _$CrossEnvelopeToJson(this);
}
''');

        final pubGet = await Process.run('dart', [
          'pub',
          'get',
        ], workingDirectory: temporary.path);
        expect(
          pubGet.exitCode,
          0,
          reason: '${pubGet.stdout}\n${pubGet.stderr}',
        );
        final build = await Process.run('dart', [
          'run',
          'build_runner',
          'build',
        ], workingDirectory: temporary.path);
        expect(build.exitCode, 0, reason: '${build.stdout}\n${build.stderr}');
        final analyze = await Process.run('dart', [
          'analyze',
          '--fatal-infos',
        ], workingDirectory: temporary.path);
        expect(
          analyze.exitCode,
          0,
          reason: '${analyze.stdout}\n${analyze.stderr}',
        );

        final sameJson = File(
          p.join(temporary.path, 'lib', 'same.g.dart'),
        ).readAsStringSync();
        final crossJson = File(
          p.join(temporary.path, 'lib', 'cross.g.dart'),
        ).readAsStringSync();
        expect(sameJson, contains('User.fromJson'));
        expect(sameJson, contains('.toJson()'));
        expect(crossJson, contains('Address.fromJson'));
        expect(crossJson, contains('.toJson()'));
      } finally {
        temporary.deleteSync(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
