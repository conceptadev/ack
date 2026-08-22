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
part 'empty.g.dart';

@AckType()
final emptySchema = Ack.object({});
''',
        },
        outputs: {
          'test_pkg|lib/empty.ack.dart': decodedMatches(
            allOf([
              contains('Empty()'),
              contains('@AckType.jsonSerializable'),
              contains(r'_$EmptyFromJson'),
              contains(r'_$EmptyToJson'),
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
part 'values.g.dart';

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
part 'address.g.dart';

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
part 'person.g.dart';

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
            contains(r'_$PersonFromJson'),
            contains('_ackFromRuntimeHome'),
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
part 'pet.g.dart';

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
            isNot(contains('@AckType.jsonSerializable\nsealed class Pet')),
            contains('@AckType.jsonSerializable\nfinal class Cat extends Pet'),
            contains("String get kind => 'cat';"),
            contains("'kind': 'dog'"),
            contains('additionalProperties.entries'),
            contains(r'_$CatFromJson'),
            contains(r'_$DogToJson'),
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
part 'bad.g.dart';

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
part 'bad.g.dart';

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
part 'bad.g.dart';

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
part 'bad.g.dart';

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
part 'bad.g.dart';

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

  test('preserves a prefixed AckType qualifier on the JSON marker', () async {
    await _build(
      {
        'schema.dart': '''
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart' as annotations;

part 'schema.ack.dart';
part 'schema.g.dart';

@annotations.AckType()
final userSchema = Ack.object({'name': Ack.string()});
''',
      },
      outputs: {
        'test_pkg|lib/schema.ack.dart': decodedMatches(
          contains('@annotations.AckType.jsonSerializable'),
        ),
      },
    );
  });

  test('preserves a direct AckType qualifier on the JSON marker', () async {
    await _build(
      {
        'schema.dart':
            '''
$_imports
part 'schema.ack.dart';
part 'schema.g.dart';

@AckType()
final userSchema = Ack.object({'name': Ack.string()});
''',
      },
      outputs: {
        'test_pkg|lib/schema.ack.dart': decodedMatches(
          contains('@AckType.jsonSerializable'),
        ),
      },
    );
  });

  test(
    'preserves an unprefixed barrel AckType qualifier on the JSON marker',
    () async {
      await _build(
        {
          'annotations.dart':
              "export 'package:ack_annotations/ack_annotations.dart';",
          'schema.dart': '''
import 'package:ack/ack.dart';
import 'annotations.dart';

part 'schema.ack.dart';
part 'schema.g.dart';

@AckType()
final userSchema = Ack.object({'name': Ack.string()});
''',
        },
        outputs: {
          'test_pkg|lib/schema.ack.dart': decodedMatches(
            contains('@AckType.jsonSerializable'),
          ),
        },
      );
    },
  );

  test(
    'prefers a prefixed AckType qualifier when both imports are visible',
    () async {
      await _build(
        {
          'schema.dart': '''
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';
import 'package:ack_annotations/ack_annotations.dart' as annotations;

part 'schema.ack.dart';
part 'schema.g.dart';

@AckType()
final userSchema = Ack.object({'name': Ack.string()});
''',
        },
        outputs: {
          'test_pkg|lib/schema.ack.dart': decodedMatches(
            contains('@annotations.AckType.jsonSerializable'),
          ),
        },
      );
    },
  );

  test(
    'preserves a prefixed barrel AckType qualifier on the JSON marker',
    () async {
      await _build(
        {
          'annotations.dart':
              "export 'package:ack_annotations/ack_annotations.dart';",
          'schema.dart': '''
import 'package:ack/ack.dart';
import 'annotations.dart' as annotations show AckType;

part 'schema.ack.dart';
part 'schema.g.dart';

@annotations.AckType()
final userSchema = Ack.object({'name': Ack.string()});
''',
        },
        outputs: {
          'test_pkg|lib/schema.ack.dart': decodedMatches(
            contains('@annotations.AckType.jsonSerializable'),
          ),
        },
      );
    },
  );

  test('rejects field names that collide after bridge derivation', () async {
    final messages = <String>{};
    await _build(
      {
        'bad.dart':
            '''
$_imports
part 'bad.ack.dart';
part 'bad.g.dart';

@AckType()
final badSchema = Ack.object({
  'name': Ack.string(),
  'Name': Ack.string(),
});
''',
      },
      outputs: const {},
      onLog: (log) {
        if (log.level.name == 'SEVERE') messages.add(log.message);
      },
    );
    expect(messages.single, contains('badSchema.Name'));
    expect(messages.single, contains('_ackFromRuntimeName'));
  });

  test('rejects top-level JSON helper name collisions', () async {
    final messages = <String>{};
    await _build(
      {
        'bad.dart':
            '''
$_imports
part 'bad.ack.dart';
part 'bad.g.dart';

void _\$UserFromJson() {}

@AckType()
final userSchema = Ack.object({'name': Ack.string()});
''',
      },
      outputs: const {},
      onLog: (log) {
        if (log.level.name == 'SEVERE') messages.add(log.message);
      },
    );
    expect(messages.single, contains(r'_$UserFromJson'));
  });
}
