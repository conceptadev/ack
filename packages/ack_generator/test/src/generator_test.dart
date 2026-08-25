import 'package:ack_generator/src/builder.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

Future<void> _build(
  String source, {
  Map<String, Object>? outputs,
  void Function(LogRecord log)? onLog,
}) async {
  final readerWriter = TestReaderWriter(rootPackage: 'test_pkg');
  await readerWriter.testing.loadIsolateSources();
  await testBuilder(
    ackGenerator(BuilderOptions.empty),
    {'test_pkg|lib/schema.dart': source},
    generateFor: const {'test_pkg|lib/schema.dart'},
    readerWriter: readerWriter,
    outputs: outputs,
    onLog: onLog,
  );
}

void main() {
  test(
    'builder writes a dedicated source part from workspace packages',
    () async {
      await _build(
        '''
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

part 'schema.ack.dart';
part 'schema.g.dart';

@AckType()
final userSchema = Ack.object({'name': Ack.string()});
''',
        outputs: {
          'test_pkg|lib/schema.ack.dart': decodedMatches(
            allOf([
              contains('// GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains("part of 'schema.dart';"),
              contains('final class User'),
            ]),
          ),
        },
      );
    },
  );

  test('does not emit output without AckType declarations', () async {
    await _build('final value = 1;', outputs: const {});
  });

  test('reports the exact required part directives', () async {
    var sawError = false;
    await _build(
      '''
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

@AckType()
final userSchema = Ack.string();
''',
      outputs: const {},
      onLog: (log) {
        if (log.level.name == 'SEVERE' &&
            log.message.contains("part 'schema.ack.dart';") &&
            log.message.contains("part 'schema.g.dart';")) {
          sawError = true;
        }
      },
    );
    expect(sawError, isTrue);
  });

  test(
    'rejects a missing JSON part even when the Ack part is present',
    () async {
      var sawError = false;
      await _build(
        '''
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

part 'schema.ack.dart';

@AckType()
final userSchema = Ack.string();
''',
        outputs: const {},
        onLog: (log) {
          if (log.level.name == 'SEVERE' &&
              log.message.contains("part 'schema.g.dart';")) {
            sawError = true;
          }
        },
      );
      expect(sawError, isTrue);
    },
  );

  test('does not reject part directives with a leading ./', () async {
    var sawOurPartError = false;
    await _build(
      '''
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

part './schema.ack.dart';
part './schema.g.dart';

@AckType()
final userSchema = Ack.object({'name': Ack.string()});
''',
      outputs: const {},
      onLog: (log) {
        if (log.level.name == 'SEVERE' &&
            log.message.contains('Ack model generation requires')) {
          sawOurPartError = true;
        }
      },
    );
    expect(sawOurPartError, isFalse);
  });

  test(
    'rejects a part directive that points at a nested relative path',
    () async {
      var sawError = false;
      await _build(
        '''
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

part 'sub/schema.ack.dart';
part 'sub/schema.g.dart';

@AckType()
final userSchema = Ack.string();
''',
        outputs: const {},
        onLog: (log) {
          if (log.level.name == 'SEVERE' &&
              log.message.contains("part 'schema.ack.dart';") &&
              log.message.contains("part 'schema.g.dart';")) {
            sawError = true;
          }
        },
      );
      expect(sawError, isTrue);
    },
  );

  test('rejects a JSON part that does not match the basename', () async {
    var sawError = false;
    await _build(
      '''
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

part 'schema.ack.dart';
part 'other.g.dart';

@AckType()
final userSchema = Ack.string();
''',
      outputs: const {},
      onLog: (log) {
        if (log.level.name == 'SEVERE' &&
            log.message.contains("part 'schema.g.dart';")) {
          sawError = true;
        }
      },
    );
    expect(sawError, isTrue);
  });

  test('rejects AckType on classes', () async {
    var sawError = false;
    await _build(
      '''
import 'package:ack_annotations/ack_annotations.dart';

@AckType()
class InvalidSchema {}
''',
      outputs: const {},
      onLog: (log) {
        if (log.level.name == 'SEVERE' &&
            log.message.contains('top-level schema variables or getters')) {
          sawError = true;
        }
      },
    );
    expect(sawError, isTrue);
  });
}
