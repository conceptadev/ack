import 'dart:io';

import 'package:ack_generator/src/builder.dart';
import 'package:ack_generator/src/json/helper_names.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('build.yaml encodes the two-phase Ack JSON contract', () {
    var directory = Directory.current;
    if (!File(p.join(directory.path, 'build.yaml')).existsSync()) {
      directory = Directory(
        p.join(directory.path, 'packages', 'ack_generator'),
      );
    }
    final yaml = File(p.join(directory.path, 'build.yaml')).readAsStringSync();
    expect(yaml, contains('builder_factories: ["ackGenerator"]'));
    expect(yaml, contains('builder_factories: ["ackJsonSerializableBuilder"]'));
    expect(yaml, contains('.ack_json_serializable.g.part'));
    expect(yaml, contains('required_inputs: [".ack.dart"]'));
    expect(yaml, contains('source_gen|combining_builder'));
    expect(yaml, contains('ack_generator|ack_json_serializable'));
    expect(yaml, contains('json_serializable|json_serializable'));
    expect(yaml, isNot(contains('jsonSerializableBuilder')));
  });

  test('derived helper names stay deterministic', () {
    expect(ackFromRuntimeBridgeName('createdAt'), '_ackFromRuntimeCreatedAt');
    expect(ackToRuntimeBridgeName('createdAt'), '_ackToRuntimeCreatedAt');
    expect(jsonFromHelperName('User'), r'_$UserFromJson');
    expect(jsonToHelperName('User'), r'_$UserToJson');
    expect(ackBridgePascal('name'), ackBridgePascal('Name'));
  });

  test('JSON builder exits immediately for ordinary libraries', () async {
    final readerWriter = TestReaderWriter(rootPackage: 'test_pkg');
    await readerWriter.testing.loadIsolateSources();
    await testBuilder(
      ackJsonSerializableBuilder(BuilderOptions.empty),
      {'test_pkg|lib/plain.dart': 'final value = 1;'},
      generateFor: const {'test_pkg|lib/plain.dart'},
      readerWriter: readerWriter,
      outputs: const {},
    );
  });
}
