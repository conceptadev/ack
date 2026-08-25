import 'package:ack_generator/src/builder.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

Future<TestBuilderResult> _generate(
  String source, {
  void Function(LogRecord log)? onLog,
  Map<String, Object>? outputs,
}) async {
  final readerWriter = TestReaderWriter(rootPackage: 'test_pkg');
  await readerWriter.testing.loadIsolateSources();
  return testBuilder(
    ackGenerator(BuilderOptions.empty),
    {'test_pkg|lib/schema.dart': source},
    generateFor: const {'test_pkg|lib/schema.dart'},
    readerWriter: readerWriter,
    outputs: outputs,
    onLog: onLog,
  );
}

const _imports = '''
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

part 'schema.ack.dart';
part 'schema.g.dart';
''';

void main() {
  test('object models expose only the V2 parse and JSON contract', () async {
    await _generate(
      '''
$_imports
@AckType()
final userSchema = Ack.object({
  'name': Ack.string(),
  'nickname': Ack.string().optional(),
  'middleName': Ack.string().nullable(),
  'role': Ack.string().withDefault('member'),
});
''',
      outputs: {
        'test_pkg|lib/schema.ack.dart': decodedMatches(
          allOf([
            contains('final class User'),
            contains('@AckType.jsonSerializable'),
            contains('factory User.parse(Object? input)'),
            contains('factory User.fromJson(Map<String, dynamic> json)'),
            contains(r'static final $ack = AckModelAdapter'),
            contains('Map<String, dynamic> toJson()'),
            contains('SchemaResult<Map<String, Object?>> safeToJson()'),
            contains('User copyWith('),
            contains('deepEquals('),
            contains('deepHashCode('),
            isNot(contains('fromMap')),
            isNot(contains('toMap')),
            isNot(contains('safeToMap')),
            contains('required this.name'),
            contains('this.nickname'),
            contains('required this.middleName'),
            contains('required this.role'),
            contains(r'_$UserFromJson'),
            contains(r'_$UserToJson'),
            contains('_ackFromRuntimeName'),
            contains('_ackToRuntimeName'),
            contains('if (middleName == null)'),
            contains("result['middleName'] = null"),
            isNot(contains("if (nickname != null) 'nickname': nickname")),
            isNot(contains("value['name']")),
          ]),
        ),
      },
    );
  });

  test('value roots use their schema boundary type for JSON', () async {
    await _generate(
      '''
$_imports
@AckType()
final occurredAtSchema = Ack.datetime();
''',
      outputs: {
        'test_pkg|lib/schema.ack.dart': decodedMatches(
          allOf([
            contains('final DateTime value;'),
            contains('@AckType.jsonSerializable'),
            contains('factory OccurredAt.fromJson(String json)'),
            contains('String toJson()'),
            contains('SchemaResult<String> safeToJson()'),
            contains(
              r"_$OccurredAtFromJson(<String, dynamic>{'value': value})",
            ),
            contains(r"_$OccurredAtToJson(this)['value'] as DateTime"),
          ]),
        ),
      },
    );
  });

  test('derived and custom names are exact', () async {
    await _generate(
      '''
$_imports
@AckType()
final memberTypeSchema = Ack.string();

@AckType(name: 'IntentionalType')
final customSchema = Ack.string();
''',
      outputs: {
        'test_pkg|lib/schema.ack.dart': decodedMatches(
          allOf([
            contains('final class MemberType'),
            contains('final class IntentionalType'),
            isNot(contains('MemberTypeType')),
          ]),
        ),
      },
    );
  });

  test('rejects one-way transforms anywhere in the graph', () async {
    var sawError = false;
    await _generate(
      '''
$_imports
@AckType()
final userSchema = Ack.object({
  'age': Ack.string().transform(int.parse),
});
''',
      outputs: const {},
      onLog: (log) {
        if (log.level.name == 'SEVERE' &&
            log.message.contains('userSchema.age') &&
            log.message.contains('.codec()')) {
          sawError = true;
        }
      },
    );
    expect(sawError, isTrue);
  });

  test('rejects whitespace-altered custom names', () async {
    var sawError = false;
    await _generate(
      '''
$_imports
@AckType(name: ' User')
final userSchema = Ack.string();
''',
      outputs: const {},
      onLog: (log) {
        if (log.level.name == 'SEVERE' &&
            log.message.contains('UpperCamelCase')) {
          sawError = true;
        }
      },
    );
    expect(sawError, isTrue);
  });
}
