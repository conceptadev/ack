import 'package:ack_generator/src/builder.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:test/test.dart';

Future<void> _build(
  Map<String, String> sources, {
  required Map<String, Object> outputs,
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
  );
}

const _imports = '''
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';
''';

void main() {
  test(
    'emits a codec schema, presence semantics, extensions, and bridges',
    () async {
      await _build(
        {
          'profile.dart':
              '''
$_imports
part 'profile.ack.dart';
part 'profile.g.dart';

@AckModel()
final class Profile {
  const Profile({
    required this.bio,
    this.website,
    required this.nickname,
    this.role = 'member',
    required this.tags,
  });

  @MinLength(1)
  @MaxLength(500)
  final String bio;
  final Uri? website;
  final String? nickname;
  final String role;
  @MinItems(1)
  @UniqueItems()
  final Set<String> tags;
}
''',
        },
        outputs: {
          'test_pkg|lib/profile.ack.dart': decodedMatches(
            allOf([
              contains('final _profileSchema = Ack.object'),
              isNot(contains('final profileSchema =')),
              contains("'bio': Ack.string().minLength(1).maxLength(500)"),
              contains("'website': Ack.uri().optional()"),
              contains("'nickname': Ack.string().nullable()"),
              contains("'role': Ack.string().withDefault('member')"),
              contains('Ack.list(Ack.string())'),
              contains('.minItems(1)'),
              contains('.unique()'),
              contains('.codec<Set<String>>'),
              contains('.codec<Profile>('),
              contains(r'decode: _$ProfileFromRuntime'),
              contains(r'encode: _$ProfileToRuntime'),
              contains('abstract final class ProfileSchema'),
              contains(
                'static AckSchema<Map<String, Object?>, Profile> get schema',
              ),
              contains('static Profile parse('),
              contains('static SchemaResult<Profile> safeParse('),
              contains(
                'static Profile fromJson(Map<String, dynamic> json) => parse(json)',
              ),
              contains('static Map<String, Object?> encode('),
              contains('static SchemaResult<Map<String, Object?>> safeEncode('),
              contains('static Map<String, Object?> toJsonSchema()'),
              contains('static AckSchemaModel toSchemaModel()'),
              contains('_profileSchema.parse(value, debugName: debugName)!'),
              contains('_profileSchema.encode(value, debugName: debugName)!'),
              contains(r'Profile _$ProfileFromRuntime'),
              contains(r'_$ProfileFromJson'),
              contains(r'Map<String, Object?> _$ProfileToRuntime'),
              contains("result['nickname'] = null"),
              contains('extension ProfileAck on Profile'),
              contains('Map<String, dynamic> toJson()'),
              contains('SchemaResult<Map<String, Object?>> safeToJson()'),
              contains('ProfileSchema.encode(this)'),
              contains('ProfileSchema.safeEncode(this)'),
              contains('_ackProfileFromRuntimeBio'),
              contains('_ackProfileToRuntimeTags'),
            ]),
          ),
        },
      );
    },
  );

  test(
    'emits escape-hatch schemas and built-in recursive type coverage',
    () async {
      await _build(
        {
          'types.dart':
              '''
$_imports
part 'types.ack.dart';
part 'types.g.dart';

final class Color {
  const Color(this.value);
  final String value;
}

AckSchema<String, Color> colorSchema() => Ack.string().codec<Color>(
  decode: Color.new,
  encode: (color) => color.value,
);

AckSchema<Map<String, Object?>, Map<String, int>> scoresSchema() =>
    Ack.object({}, additionalProperties: true).codec<Map<String, int>>(
      decode: (value) => value.map((key, item) => MapEntry(key, item as int)),
      encode: (value) => value,
    );

enum Role { admin, member }

@AckModel()
final class Record {
  const Record({
    required this.color,
    required this.scores,
    required this.role,
    required this.createdAt,
    required this.website,
    required this.timeout,
    required this.names,
  });

  @AckField(schema: colorSchema)
  final Color color;
  @AckField(schema: scoresSchema)
  final Map<String, int> scores;
  final Role role;
  final DateTime createdAt;
  final Uri website;
  final Duration timeout;
  final List<List<String>> names;
}
''',
        },
        outputs: {
          'test_pkg|lib/types.ack.dart': decodedMatches(
            allOf([
              contains("'color': colorSchema()"),
              contains("'scores': scoresSchema()"),
              contains("'role': Ack.enumValues(Role.values)"),
              contains("'createdAt': Ack.datetime()"),
              contains("'website': Ack.uri()"),
              contains("'timeout': Ack.duration()"),
              contains("'names': Ack.list(Ack.list(Ack.string()))"),
              contains('Map<String, int> _ackRecordFromRuntimeScores'),
              contains('List<List<String>> _ackRecordFromRuntimeNames'),
            ]),
          ),
        },
      );
    },
  );

  test('computes case-style and JsonKey schema keys once', () async {
    await _build(
      {
        'account.dart':
            '''
$_imports
part 'account.ack.dart';
part 'account.g.dart';

@AckModel(caseStyle: AckCaseStyle.snake)
final class Account {
  const Account({required this.firstName, required this.imageUrl});

  final String firstName;
  @JsonKey(name: 'avatar')
  final String imageUrl;
}
''',
      },
      outputs: {
        'test_pkg|lib/account.ack.dart': decodedMatches(
          allOf([
            contains("'first_name': Ack.string()"),
            contains("'avatar': Ack.string()"),
            isNot(contains("'firstName':")),
            isNot(contains("'image_url':")),
          ]),
        ),
      },
    );
  });

  test(
    'preserves prefixed field types and same-named import identity',
    () async {
      await _build(
        {
          'a.dart':
              '''
$_imports
part 'a.ack.dart';
part 'a.g.dart';

@AckModel()
final class Address {
  const Address({required this.city});
  final String city;
}
''',
          'b.dart': '''
final class Address {
  const Address();
}
''',
          'order.dart':
              '''
$_imports
import 'a.dart' as a;
import 'b.dart' as b;
part 'order.ack.dart';
part 'order.g.dart';

@AckModel()
final class Order {
  const Order({required this.shipping});
  final a.Address shipping;
}

// Keep the second same-named import semantically used.
const Type otherAddressType = b.Address;
''',
        },
        outputs: {
          'test_pkg|lib/a.ack.dart': decodedMatches(
            allOf([
              contains('final _addressSchema'),
              contains('abstract final class AddressSchema'),
            ]),
          ),
          'test_pkg|lib/order.ack.dart': decodedMatches(
            allOf([
              contains("'shipping': a.AddressSchema.schema"),
              contains('a.Address _ackOrderFromRuntimeShipping'),
              isNot(contains('b.AddressSchema')),
            ]),
          ),
        },
      );
    },
  );

  test(
    'emits raw union branches, public codecs, and exhaustive dispatch',
    () async {
      await _build(
        {
          'pet.dart':
              '''
$_imports
part 'pet.ack.dart';
part 'pet.g.dart';

@AckModel(discriminatorKey: 'type')
sealed class Pet {
  const Pet({required this.id});
  final String id;
}

@AckModel(discriminatorValue: 'cat')
final class Cat extends Pet {
  const Cat({required super.id, required this.lives});
  @Min(1)
  @Max(9)
  final int lives;
}

final class Dog extends Pet {
  const Dog({required super.id, required this.breed});
  final String breed;
}
''',
        },
        outputs: {
          'test_pkg|lib/pet.ack.dart': decodedMatches(
            allOf([
              contains('final _catObject = Ack.object'),
              contains("'id': Ack.string()"),
              contains("'lives': Ack.integer().min(1).max(9)"),
              contains('final _catSchema = _catObject.codec<Cat>'),
              contains('final _dogSchema = _dogObject.codec<Dog>'),
              contains('final _petSchema ='),
              contains('abstract final class CatSchema'),
              contains('abstract final class DogSchema'),
              contains('abstract final class PetSchema'),
              isNot(contains('final catSchema =')),
              isNot(contains('final dogSchema =')),
              isNot(contains('final petSchema =')),
              contains('Ack.discriminated('),
              contains("discriminatorKey: 'type'"),
              contains("schemas: {'cat': _catObject, 'Dog': _dogObject}"),
              contains('.codec<Pet>('),
              contains("'cat' => _\$CatFromRuntime(value)"),
              contains("'Dog' => _\$DogFromRuntime(value)"),
              contains('encode: (model) => switch (model)'),
              contains(r'Cat() => _$CatToRuntime(model)'),
              contains(r'Dog() => _$DogToRuntime(model)'),
              contains('extension PetAck on Pet'),
            ]),
          ),
        },
      );
    },
  );

  test(
    'uses an exact custom facade name with a derived private backing',
    () async {
      await _build(
        {
          'account.dart':
              '''
$_imports
part 'account.ack.dart';
part 'account.g.dart';

@AckModel(schemaName: 'WireAccountSchema')
final class Account {
  const Account({required this.id});
  final String id;
}
''',
        },
        outputs: {
          'test_pkg|lib/account.ack.dart': decodedMatches(
            allOf([
              contains('final _accountSchema = Ack.object'),
              contains('abstract final class WireAccountSchema'),
              contains('WireAccountSchema.encode(this)'),
              isNot(contains('abstract final class AccountSchema')),
            ]),
          ),
        },
      );
    },
  );

  test('qualifies facade APIs through a prefixed Ack import', () async {
    await _build(
      {
        'account.dart': '''
import 'package:ack/ack.dart' as ack
    show Ack, AckSchema, AckSchemaModel, AckSchemaModelExtension, SchemaResult;
import 'package:ack_annotations/ack_annotations.dart' as annotations
    show AckModel;

part 'account.ack.dart';
part 'account.g.dart';

@annotations.AckModel()
final class Account {
  const Account();
}
''',
      },
      outputs: {
        'test_pkg|lib/account.ack.dart': decodedMatches(
          allOf([
            contains('ack.Ack.object'),
            contains('ack.AckSchema<Map<String, Object?>, Account>'),
            contains('ack.SchemaResult<Account>'),
            contains('ack.AckSchemaModel toSchemaModel()'),
            contains('ack.AckSchemaModelExtension(_accountSchema)'),
          ]),
        ),
      },
    );
  });
}
