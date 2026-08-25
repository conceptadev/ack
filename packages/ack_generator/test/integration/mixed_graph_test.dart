import 'package:ack_generator/src/builder.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

Future<void> _build(
  Builder builder,
  String source, {
  required Map<String, Object> outputs,
  void Function(LogRecord log)? onLog,
}) async {
  final readerWriter = TestReaderWriter(rootPackage: 'test_pkg');
  await readerWriter.testing.loadIsolateSources();
  await testBuilder(
    builder,
    {'test_pkg|lib/models.dart': source},
    generateFor: const {'test_pkg|lib/models.dart'},
    readerWriter: readerWriter,
    outputs: outputs,
    onLog: onLog,
  );
}

const _parts = """
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

part 'models.g.dart';
part 'models.ack.dart';
part 'models.ack.g.dart';
""";

void main() {
  test(
    'unrelated legacy and modern declarations coexist in one library',
    () async {
      const source =
          """
$_parts
@AckType()
final legacySchema = Ack.object({'id': Ack.string()});

@AckInfer()
final modernSchema = Ack.object({'name': Ack.string()});
""";

      await _build(
        ackGenerator(BuilderOptions.empty),
        source,
        outputs: {
          'test_pkg|lib/models.g.dart': decodedMatches(
            contains('extension type LegacyType('),
          ),
        },
      );
      await _build(
        ackModelBuilder(BuilderOptions.empty),
        source,
        outputs: {
          'test_pkg|lib/models.ack.dart': decodedMatches(
            contains('final class Modern'),
          ),
        },
      );
    },
  );

  test('modern schemas reject a nested legacy reference graph', () async {
    var sawDiagnostic = false;
    await _build(
      ackModelBuilder(BuilderOptions.empty),
      """
$_parts
@AckType()
final addressSchema = Ack.object({'city': Ack.string()});

@AckInfer()
final userSchema = Ack.object({'address': addressSchema});
""",
      outputs: const {},
      onLog: (log) {
        if (log.level.name == 'SEVERE' &&
            log.message.contains('userSchema.address') &&
            log.message.contains('migrate this connected graph together')) {
          sawDiagnostic = true;
        }
      },
    );
    expect(sawDiagnostic, isTrue);
  });

  test('legacy schemas reject a nested modern reference graph', () async {
    var sawDiagnostic = false;
    await _build(
      ackGenerator(BuilderOptions.empty),
      """
$_parts
@AckInfer()
final addressSchema = Ack.object({'city': Ack.string()});

@AckType()
final userSchema = Ack.object({'address': addressSchema});
""",
      outputs: const {},
      onLog: (log) {
        if (log.level.name == 'SEVERE' &&
            log.message.contains('migrate this connected graph together')) {
          sawDiagnostic = true;
        }
      },
    );
    expect(sawDiagnostic, isTrue);
  });
}
