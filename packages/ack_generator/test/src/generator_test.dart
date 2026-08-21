import 'package:ack_generator/src/generator.dart';
import 'package:build_test/build_test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import '../test_utils/test_assets.dart';

void main() {
  group('AckSchemaGenerator', () {
    late AckSchemaGenerator generator;

    setUp(() {
      generator = AckSchemaGenerator();
    });

    test('generates immutable classes for annotated schemas', () async {
      final builder = SharedPartBuilder([generator], 'ack');

      await testBuilder(
        builder,
        {
          ...allAssets,
          'test_pkg|lib/schema.dart': '''
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

@AckType()
final userSchema = Ack.object({
  'name': Ack.string(),
});

@AckType(name: 'Status')
AckSchema<String> get statusSchema => Ack.string();
''',
        },
        outputs: {
          'test_pkg|lib/schema.ack.g.part': decodedMatches(
            allOf([
              contains('final class User'),
              contains('final String name;'),
              contains('factory User.parse(Object? input)'),
              contains('factory User.fromJson(Map<String, dynamic> json)'),
              contains('Map<String, dynamic> toJson()'),
              contains('final class Status'),
              contains('final String value;'),
              isNot(contains('extension type')),
              isNot(contains('implements Map<String, Object?>')),
            ]),
          ),
        },
      );
    });

    test('does not emit output when no AckType declarations exist', () async {
      final builder = SharedPartBuilder([generator], 'ack');

      await testBuilder(builder, {
        ...allAssets,
        'test_pkg|lib/plain.dart': '''
class PlainData {
  final String id;
  PlainData(this.id);
}
''',
      }, outputs: const {});
    });

    test('leaves shared-part framing to source_gen', () async {
      final builder = SharedPartBuilder([generator], 'ack');

      await testBuilder(
        builder,
        {
          ...allAssets,
          'test_pkg|lib/model.dart': '''
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

@AckType()
final modelSchema = Ack.object({
  'id': Ack.string(),
});
''',
        },
        outputs: {
          'test_pkg|lib/model.ack.g.part': decodedMatches(
            allOf([
              contains('// AckSchemaGenerator'),
              isNot(contains('// GENERATED CODE - DO NOT MODIFY BY HAND')),
              isNot(contains("part of 'model.dart';")),
            ]),
          ),
        },
      );
    });

    test('reports invalid AckType placement on classes', () async {
      final builder = SharedPartBuilder([generator], 'ack');
      var sawPlacementError = false;

      await testBuilder(
        builder,
        {
          ...allAssets,
          'test_pkg|lib/bad.dart': '''
import 'package:ack_annotations/ack_annotations.dart';

@AckType()
class BadSchema {}
''',
        },
        outputs: const {},
        onLog: (log) {
          if (log.level.name == 'SEVERE') {
            sawPlacementError = true;
            expect(
              log.message,
              contains('top-level schema variables or getters'),
            );
          }
        },
      );

      expect(sawPlacementError, isTrue);
    });

    test('reports invalid AckType placement on instance getters', () async {
      final builder = SharedPartBuilder([generator], 'ack');
      var sawPlacementError = false;

      await testBuilder(
        builder,
        {
          ...allAssets,
          'test_pkg|lib/bad.dart': '''
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

class BadSchema {
  @AckType()
  AckSchema<String> get valueSchema => Ack.string();
}
''',
        },
        outputs: const {},
        onLog: (log) {
          if (log.level.name == 'SEVERE') {
            sawPlacementError = true;
            expect(
              log.message,
              contains('top-level schema variables or getters'),
            );
          }
        },
      );

      expect(sawPlacementError, isTrue);
    });
  });
}
