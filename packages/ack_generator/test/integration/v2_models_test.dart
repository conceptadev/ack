import 'package:ack_generator/src/builder.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

Future<void> _build(
  Map<String, String> sources, {
  required Map<String, Object> outputs,
  void Function(LogRecord log)? onLog,
}) async {
  final readerWriter = TestReaderWriter(rootPackage: 'test_pkg');
  await readerWriter.testing.loadIsolateSources();
  await testBuilder(
    ackGenerator(BuilderOptions.empty),
    {
      for (final entry in sources.entries)
        'test_pkg|lib/${entry.key}': entry.value,
    },
    generateFor: {for (final path in sources.keys) 'test_pkg|lib/$path'},
    readerWriter: readerWriter,
    outputs: outputs,
    onLog: onLog,
  );
}

const _imports = '''
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';
''';

void main() {
  test(
    'emits empty objects without malformed argument or map commas',
    () async {
      await _build(
        {
          'empty.dart':
              '''
$_imports
part 'empty.ack.dart';

@AckType()
final emptySchema = Ack.object({});
''',
        },
        outputs: {
          'test_pkg|lib/empty.ack.dart': decodedMatches(
            allOf([
              contains('Empty()'),
              contains('return Empty();'),
              contains('return <String, Object?>{};'),
              isNot(contains('\n  ,')),
            ]),
          ),
        },
      );
    },
  );

  test(
    'emits enums, num, literals, codecs, and nested immutable lists',
    () async {
      await _build(
        {
          'values.dart':
              '''
$_imports
part 'values.ack.dart';

enum Role { admin, member }

@AckType()
final metricsSchema = Ack.object({
  'amount': Ack.number(),
  'state': Ack.literal('ready'),
  'role': Ack.enumValues(Role.values),
  'dates': Ack.list(Ack.list(Ack.date())),
});
''',
        },
        outputs: {
          'test_pkg|lib/values.ack.dart': decodedMatches(
            allOf([
              contains('required this.amount'),
              contains('required this.state'),
              contains('required this.role'),
              contains('required List<List<DateTime>> dates'),
              contains('(item) => List<DateTime>.unmodifiable(item.map'),
            ]),
          ),
        },
      );
    },
  );

  test('resolves direct, prefixed, and re-exported model references', () async {
    await _build(
      {
        'address.dart':
            '''
$_imports
part 'address.ack.dart';

@AckType()
final addressSchema = Ack.object({'city': Ack.string()});
''',
        'exports.dart': "export 'address.dart';",
        'person.dart':
            '''
$_imports
import 'address.dart' as direct;
import 'exports.dart' as exported;
part 'person.ack.dart';

@AckType()
final personSchema = Ack.object({
  'home': direct.addressSchema,
  'history': Ack.list(exported.addressSchema),
});
''',
      },
      outputs: {
        'test_pkg|lib/address.ack.dart': decodedMatches(
          contains('final class Address'),
        ),
        'test_pkg|lib/person.ack.dart': decodedMatches(
          allOf([
            contains('required this.home'),
            contains('required List<exported.Address> history'),
            contains(r'direct.Address.$ack.fromRuntime'),
            contains(r'exported.Address.$ack.toRuntime'),
          ]),
        ),
      },
    );
  });

  test('emits sealed unions with final same-library branches', () async {
    await _build(
      {
        'pet.dart':
            '''
$_imports
part 'pet.ack.dart';

@AckType()
final catSchema = Ack.object({'kind': Ack.literal('cat'), 'lives': Ack.integer()});

@AckType()
final dogSchema = Ack.object({'bark': Ack.boolean()}).passthrough();

@AckType()
final petSchema = Ack.discriminated(
  discriminatorKey: 'kind',
  schemas: {'cat': catSchema, 'dog': dogSchema},
);
''',
      },
      outputs: {
        'test_pkg|lib/pet.ack.dart': decodedMatches(
          allOf([
            contains('sealed class Pet'),
            contains('final class Cat extends Pet'),
            contains('final class Dog extends Pet'),
            contains("String get kind => 'cat';"),
            contains("'kind': 'dog'"),
            contains('...additionalProperties'),
          ]),
        ),
      },
    );
  });

  test(
    'rejects anonymous objects and generated member collisions with paths',
    () async {
      final messages = <String>{};
      await _build(
        {
          'bad.dart':
              '''
$_imports
part 'bad.ack.dart';

@AckType()
final badSchema = Ack.object({'toJson': Ack.string()});
''',
        },
        outputs: const {},
        onLog: (log) {
          if (log.level.name == 'SEVERE') messages.add(log.message);
        },
      );
      expect(messages.single, contains('badSchema.toJson'));
    },
  );

  test('rejects Dart keywords used as generated field names', () async {
    final messages = <String>{};
    await _build(
      {
        'bad.dart':
            '''
$_imports
part 'bad.ack.dart';

@AckType()
final badSchema = Ack.object({'class': Ack.string()});
''',
      },
      outputs: const {},
      onLog: (log) {
        if (log.level.name == 'SEVERE') messages.add(log.message);
      },
    );
    expect(messages.single, contains('badSchema.class'));
  });

  test(
    'rejects union discriminators that collide with generated APIs',
    () async {
      final messages = <String>{};
      await _build(
        {
          'bad.dart':
              '''
$_imports
part 'bad.ack.dart';

@AckType()
final catSchema = Ack.object({'lives': Ack.integer()});

@AckType()
final petSchema = Ack.discriminated(
  discriminatorKey: 'toJson',
  schemas: {'cat': catSchema},
);
''',
        },
        outputs: const {},
        onLog: (log) {
          if (log.level.name == 'SEVERE') messages.add(log.message);
        },
      );
      expect(messages.single, contains('petSchema.toJson'));
    },
  );

  test('rejects broad union discriminator fields', () async {
    final messages = <String>{};
    await _build(
      {
        'bad.dart':
            '''
$_imports
part 'bad.ack.dart';

@AckType()
final catSchema = Ack.object({
  'kind': Ack.string(),
  'lives': Ack.integer(),
});

@AckType()
final petSchema = Ack.discriminated(
  discriminatorKey: 'kind',
  schemas: {'cat': catSchema},
);
''',
      },
      outputs: const {},
      onLog: (log) {
        if (log.level.name == 'SEVERE') messages.add(log.message);
      },
    );
    expect(messages.single, contains('catSchema.kind'));
  });

  test('rejects passthrough helper namespace collisions', () async {
    final messages = <String>{};
    await _build(
      {
        'bad.dart':
            '''
$_imports
part 'bad.ack.dart';

Object? _ackImmutableCopyValue(Object? value) => value;

@AckType()
final bagSchema = Ack.object({}).passthrough();
''',
      },
      outputs: const {},
      onLog: (log) {
        if (log.level.name == 'SEVERE') messages.add(log.message);
      },
    );
    expect(messages.single, contains('_ackImmutableCopyValue'));
  });
}
