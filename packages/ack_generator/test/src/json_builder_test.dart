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
    expect(yaml, contains('ack_models:'));
    expect(yaml, contains('builder_factories: ["ackModelBuilder"]'));
    expect(yaml, contains('build_extensions: {".dart": [".ack.dart"]}'));
    expect(yaml, contains('ack_model_json:'));
    expect(yaml, contains('builder_factories: ["ackModelJsonBuilder"]'));
    expect(
      yaml,
      contains('build_extensions: {".dart": [".ack_model_json.g.part"]}'),
    );
    expect(yaml, contains('required_inputs: [".ack.dart"]'));
    expect(yaml, contains('ack_generator|ack_model_json'));
    // The JSON phase is a shared part, so the ordinary combining builder owns
    // `.g.dart` and merges Ack output with any json_serializable output.
    expect(yaml, contains('source_gen|combining_builder'));
    // Ack 2 removed the legacy `@AckType` builder.
    expect(yaml, isNot(contains('ackGenerator')));
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
      ackModelJsonBuilder(BuilderOptions.empty),
      {'test_pkg|lib/plain.dart': 'final value = 1;'},
      generateFor: const {'test_pkg|lib/plain.dart'},
      readerWriter: readerWriter,
      outputs: const {},
    );
  });

  test('the JSON builder writes a shared part for the combining builder', () {
    final builder = ackModelJsonBuilder(BuilderOptions.empty);

    expect(builder.buildExtensions, {
      '.dart': ['.ack_model_json.g.part'],
    });
  });
}
