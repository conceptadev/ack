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
  Map<String, String> supportingSources = const {},
}) async {
  final readerWriter = TestReaderWriter(rootPackage: 'test_pkg');
  await readerWriter.testing.loadIsolateSources();
  await testBuilder(
    builder,
    {
      'test_pkg|lib/models.dart': source,
      for (final entry in supportingSources.entries)
        'test_pkg|lib/${entry.key}': entry.value,
    },
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
            log.message.contains('userSchema.address') &&
            log.message.contains('migrate this connected graph together')) {
          sawDiagnostic = true;
        }
      },
    );
    expect(sawDiagnostic, isTrue);
  });

  test('class-first models reject a nested legacy generated type', () async {
    var sawDiagnostic = false;
    await _build(
      ackModelBuilder(BuilderOptions.empty),
      """
$_parts
@AckType()
final addressSchema = Ack.object({'city': Ack.string()});

@AckModel()
final class User with _\$UserAck {
  const User({required this.addresses});

  final List<AddressType> addresses;
}
""",
      outputs: const {},
      onLog: (log) {
        if (log.level.name == 'SEVERE' &&
            log.message.contains('User.addresses') &&
            log.message.contains('migrate this connected graph together')) {
          sawDiagnostic = true;
        }
      },
    );
    expect(sawDiagnostic, isTrue);
  });

  test('class-first models reject a scalar legacy generated type', () async {
    var sawDiagnostic = false;
    await _build(
      ackModelBuilder(BuilderOptions.empty),
      """
$_parts
@AckType()
final addressSchema = Ack.object({'city': Ack.string()});

@AckModel()
final class User with _\$UserAck {
  const User({required this.address});

  final AddressType address;
}
""",
      outputs: const {},
      onLog: (log) {
        if (log.level.name == 'SEVERE' &&
            log.message.contains('User.address') &&
            log.message.contains('migrate this connected graph together')) {
          sawDiagnostic = true;
        }
      },
    );
    expect(sawDiagnostic, isTrue);
  });

  test('class-first models reject a resolved legacy generated type', () async {
    const source =
        """
$_parts
@AckType()
final addressSchema = Ack.object({'city': Ack.string()});

@AckModel()
final class User with _\$UserAck {
  const User({required this.addresses});

  final List<AddressType> addresses;
}
""";
    final readerWriter = TestReaderWriter(rootPackage: 'test_pkg');
    await readerWriter.testing.loadIsolateSources();
    await testBuilder(
      ackGenerator(BuilderOptions.empty),
      {'test_pkg|lib/models.dart': source},
      generateFor: const {'test_pkg|lib/models.dart'},
      readerWriter: readerWriter,
      outputs: {
        'test_pkg|lib/models.g.dart': decodedMatches(
          contains('extension type AddressType('),
        ),
      },
    );
    final generatedAsset = readerWriter.testing.assets.singleWhere(
      (asset) => asset.path.endsWith('/models.g.dart'),
    );
    final generatedSource = readerWriter.testing.readString(generatedAsset);
    final resolvedReaderWriter = TestReaderWriter(rootPackage: 'test_pkg');
    await resolvedReaderWriter.testing.loadIsolateSources();

    var sawDiagnostic = false;
    await testBuilder(
      ackModelBuilder(BuilderOptions.empty),
      {
        'test_pkg|lib/models.dart': source,
        'test_pkg|lib/models.g.dart': generatedSource,
      },
      generateFor: const {'test_pkg|lib/models.dart'},
      readerWriter: resolvedReaderWriter,
      outputs: const {},
      onLog: (log) {
        if (log.level.name == 'SEVERE' &&
            log.message.contains('User.addresses') &&
            log.message.contains('migrate this connected graph together')) {
          sawDiagnostic = true;
        }
      },
    );
    expect(sawDiagnostic, isTrue);
  });

  test('class-first models reject a resolved scalar legacy type', () async {
    const source =
        """
$_parts
@AckType()
final addressSchema = Ack.object({'city': Ack.string()});

@AckModel()
final class User with _\$UserAck {
  const User({required this.address});

  final AddressType address;
}
""";
    final readerWriter = TestReaderWriter(rootPackage: 'test_pkg');
    await readerWriter.testing.loadIsolateSources();
    await testBuilder(
      ackGenerator(BuilderOptions.empty),
      {'test_pkg|lib/models.dart': source},
      generateFor: const {'test_pkg|lib/models.dart'},
      readerWriter: readerWriter,
      outputs: {
        'test_pkg|lib/models.g.dart': decodedMatches(
          contains('extension type AddressType('),
        ),
      },
    );
    final generatedAsset = readerWriter.testing.assets.singleWhere(
      (asset) => asset.path.endsWith('/models.g.dart'),
    );
    final generatedSource = readerWriter.testing.readString(generatedAsset);
    final resolvedReaderWriter = TestReaderWriter(rootPackage: 'test_pkg');
    await resolvedReaderWriter.testing.loadIsolateSources();

    var sawDiagnostic = false;
    await testBuilder(
      ackModelBuilder(BuilderOptions.empty),
      {
        'test_pkg|lib/models.dart': source,
        'test_pkg|lib/models.g.dart': generatedSource,
      },
      generateFor: const {'test_pkg|lib/models.dart'},
      readerWriter: resolvedReaderWriter,
      outputs: const {},
      onLog: (log) {
        if (log.level.name == 'SEVERE' &&
            log.message.contains('User.address') &&
            log.message.contains('migrate this connected graph together')) {
          sawDiagnostic = true;
        }
      },
    );
    expect(sawDiagnostic, isTrue);
  });

  test('legacy schemas reject a nested class-first facade', () async {
    var sawDiagnostic = false;
    await _build(
      ackGenerator(BuilderOptions.empty),
      """
$_parts
@AckModel()
final class Address with _\$AddressAck {
  const Address({required this.city});

  final String city;
}

@AckType()
final userSchema = Ack.object({
  'addresses': Ack.list(AddressSchema.schema),
});
""",
      outputs: const {},
      onLog: (log) {
        if (log.level.name == 'SEVERE' &&
            log.message.contains('userSchema.addresses') &&
            log.message.contains('migrate this connected graph together')) {
          sawDiagnostic = true;
        }
      },
    );
    expect(sawDiagnostic, isTrue);
  });

  for (final entry in {
    'scalar': 'AddressSchema.schema',
    'parenthesized': '(AddressSchema.schema)',
    'postfix non-null assertion': 'AddressSchema.schema!',
  }.entries) {
    test(
      'legacy schemas reject ${entry.key} class-first facade references',
      () async {
        var sawDiagnostic = false;
        await _build(
          ackGenerator(BuilderOptions.empty),
          '''
$_parts
@AckModel()
final class Address with _\$AddressAck {
  const Address({required this.city});

  final String city;
}

@AckType()
final userSchema = Ack.object({'address': ${entry.value}});
''',
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
      },
    );
  }

  test('legacy schemas reject class-first facades through barrels', () async {
    var sawDiagnostic = false;
    await _build(
      ackGenerator(BuilderOptions.empty),
      '''
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';
import 'address_models.dart';

part 'models.g.dart';
part 'models.ack.dart';
part 'models.ack.g.dart';

@AckType()
final userSchema = Ack.object({'address': AddressSchema.schema});
''',
      supportingSources: const {
        'address_models.dart': "export 'address.dart';\n",
        'address.dart': '''
import 'package:ack_annotations/ack_annotations.dart';

@AckModel()
final class Address {
  const Address({required this.city});

  final String city;
}
''',
      },
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

  test(
    'legacy schemas reject an unparsed field instead of dropping it',
    () async {
      var sawDiagnostic = false;
      await _build(
        ackGenerator(BuilderOptions.empty),
        '''
$_parts
@AckType()
final userSchema = Ack.object({'name': (Ack.string())});
''',
        outputs: const {},
        onLog: (log) {
          if (log.level.name == 'SEVERE' &&
              log.message.contains('userSchema.name') &&
              log.message.contains('unsupported schema expression')) {
            sawDiagnostic = true;
          }
        },
      );
      expect(sawDiagnostic, isTrue);
    },
  );
}
