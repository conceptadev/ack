import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

Future<ProcessResult> _run(Directory directory, List<String> arguments) =>
    Process.run('dart', arguments, workingDirectory: directory.path);

void _expectSuccess(ProcessResult result, String command) {
  expect(
    result.exitCode,
    0,
    reason:
        '$command failed\nSTDOUT:\n${result.stdout}\nSTDERR:\n${result.stderr}',
  );
}

Map<String, String> _generatedFiles(Directory directory) => {
  for (final file
      in directory
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (file) =>
                file.path.endsWith('.ack.dart') ||
                file.path.endsWith('.g.dart'),
          ))
    p.relative(file.path, from: directory.path): file.readAsStringSync(),
};

void main() {
  test(
    'class-first models compile and preserve the runtime contract',
    () async {
      var projectRoot = Directory.current;
      while (!Directory(
        p.join(projectRoot.path, 'packages', 'ack_generator'),
      ).existsSync()) {
        projectRoot = projectRoot.parent;
      }
      final temporary = await Directory.systemTemp.createTemp(
        'ack_class_first_runtime_',
      );
      try {
        Directory(p.join(temporary.path, 'lib')).createSync();
        Directory(p.join(temporary.path, 'test')).createSync();
        File(p.join(temporary.path, 'pubspec.yaml')).writeAsStringSync('''
name: ack_class_first_runtime
publish_to: none
environment:
  sdk: '>=3.9.0 <4.0.0'
dependencies:
  ack:
    path: ${p.join(projectRoot.path, 'packages', 'ack')}
  ack_annotations:
    path: ${p.join(projectRoot.path, 'packages', 'ack_annotations')}
  json_annotation: ^4.11.0
dev_dependencies:
  ack_generator:
    path: ${p.join(projectRoot.path, 'packages', 'ack_generator')}
  build_runner: ^2.15.0
  json_serializable: ^6.14.1
  test: ^1.29.0
dependency_overrides:
  ack:
    path: ${p.join(projectRoot.path, 'packages', 'ack')}
  ack_annotations:
    path: ${p.join(projectRoot.path, 'packages', 'ack_annotations')}
''');
        File(p.join(temporary.path, 'lib', 'alpha.dart')).writeAsStringSync(
          'final class Item { const Item(this.value); final String value; }\n',
        );
        File(p.join(temporary.path, 'lib', 'beta.dart')).writeAsStringSync(
          'final class Item { const Item(this.value); final int value; }\n',
        );
        File(p.join(temporary.path, 'lib', 'models.dart')).writeAsStringSync(
          r'''
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';
import 'package:json_annotation/json_annotation.dart' show JsonSerializable;

import 'alpha.dart' as alpha;
import 'beta.dart' as beta;

part 'models.ack.dart';
part 'models.g.dart';

final class Color {
  const Color(this.hex);
  final String hex;

  @override
  bool operator ==(Object other) => other is Color && other.hex == hex;

  @override
  int get hashCode => hex.hashCode;
}

AckSchema<String, Color> colorSchema() => Ack.string().codec<Color>(
  decode: Color.new,
  encode: (color) => color.hex,
);

AckSchema<String, alpha.Item> alphaItemSchema() => Ack.string()
    .codec<alpha.Item>(decode: alpha.Item.new, encode: (item) => item.value);

AckSchema<int, beta.Item> betaItemSchema() => Ack.integer()
    .codec<beta.Item>(decode: beta.Item.new, encode: (item) => item.value);

@AckModel()
final class Profile with _$ProfileAck {
  const Profile({
    required this.name,
    this.website,
    required this.nickname,
    this.role = 'member',
    required this.tags,
    required this.color,
  });

  final String name;
  final Uri? website;
  final String? nickname;
  final String role;
  @UniqueItems()
  final Set<String> tags;
  @AckField(schema: colorSchema)
  final Color color;

  static final fromJson = ProfileSchema.fromJson;
}

@AckModel(caseStyle: AckCaseStyle.snake)
final class Account with _$AccountAck {
  const Account({required this.firstName, required this.imageUrl});
  final String firstName;
  @JsonKey(name: 'avatar')
  final Uri imageUrl;

  static final fromJson = AccountSchema.fromJson;
}

@AckModel(additionalProperties: AckAdditionalPropertiesMode.capture)
final class Config with _$ConfigAck {
  const Config({
    required this.name,
    this.additionalProperties = const {},
  });
  final String name;
  final Map<String, Object?> additionalProperties;
}

@AckModel(
  caseStyle: AckCaseStyle.snake,
  additionalProperties: AckAdditionalPropertiesMode.capture,
  additionalPropertiesField: 'extraValues',
)
final class CaseStyledExtras with _$CaseStyledExtrasAck {
  const CaseStyledExtras({
    required this.displayName,
    this.extraValues = const {},
  });
  final String displayName;
  final Map<String, Object?> extraValues;
}

@AckModel(additionalProperties: AckAdditionalPropertiesMode.discard)
final class Loose with _$LooseAck {
  const Loose({required this.name});
  final String name;
}

@AckModel()
final class ImportedPair with _$ImportedPairAck {
  const ImportedPair({required this.left, required this.right});
  @AckField(schema: alphaItemSchema)
  final alpha.Item left;
  @AckField(schema: betaItemSchema)
  final beta.Item right;
}

@AckModel(discriminatorKey: 'type')
sealed class Pet with _$PetAck {
  const Pet({required this.id});
  final String id;
}

@AckModel(discriminatorValue: 'cat')
final class Cat extends Pet with _$CatAck {
  const Cat({required super.id, required this.lives});
  final int lives;
}

final class Dog extends Pet with _$DogAck {
  const Dog({required super.id, required this.breed});
  final String breed;
  String get type => 'Dog';
}

@AckType()
final legacySchema = Ack.object({'enabled': Ack.boolean()});

@JsonSerializable()
final class PlainJson {
  const PlainJson({required this.value});
  factory PlainJson.fromJson(Map<String, dynamic> json) =>
      _$PlainJsonFromJson(json);
  final String value;
  Map<String, dynamic> toJson() => _$PlainJsonToJson(this);
}
''',
        );
        File(
          p.join(temporary.path, 'test', 'runtime_test.dart'),
        ).writeAsStringSync(r'''
import 'package:ack_class_first_runtime/alpha.dart' as alpha;
import 'package:ack_class_first_runtime/beta.dart' as beta;
import 'package:ack_class_first_runtime/models.dart';
import 'package:test/test.dart';

void main() {
  test('presence, defaults, collections, and escape hatches round-trip', () {
    final profile = Profile.fromJson({
      'name': 'Ada',
      'nickname': null,
      'tags': ['schema', 'dart'],
      'color': '#fff',
    });
    expect(profile.website, isNull);
    expect(profile.nickname, isNull);
    expect(profile.role, 'member');
    expect(profile.tags, {'schema', 'dart'});
    expect(profile.color.hex, '#fff');
    expect(profile.toJson(), {
      'name': 'Ada',
      'nickname': null,
      'role': 'member',
      'tags': ['schema', 'dart'],
      'color': '#fff',
    });
    expect(() => ProfileSchema.parse({'name': 'Ada'}), throwsA(anything));
    expect(ProfileSchema.safeParse({'name': 'Ada'}).isFail, isTrue);
    expect(ProfileSchema.toJsonSchema()['x-transformed'], isTrue);
    expect(
      ProfileSchema.toSchemaModel().toJsonSchema(),
      ProfileSchema.toJsonSchema(),
    );
    expect(ProfileSchema.encode(profile), profile.toJson());
    expect(ProfileSchema.safeEncode(profile).isOk, isTrue);
  });

  test('case style and JsonKey use one wire-key mapping', () {
    final account = Account.fromJson({
      'first_name': 'Ada',
      'avatar': 'https://example.com/avatar.png',
    });
    expect(account.firstName, 'Ada');
    expect(account.imageUrl.host, 'example.com');
    expect(account.toJson(), {
      'first_name': 'Ada',
      'avatar': 'https://example.com/avatar.png',
    });
  });

  test('additional properties decode and encode extras first', () {
    final config = ConfigSchema.parse({'name': 'declared', 'theme': 'dark'});
    expect(config.additionalProperties, {'theme': 'dark'});
    final spoofed = Config(
      name: 'declared',
      additionalProperties: const {'name': 'spoofed', 'theme': 'dark'},
    );
    expect(spoofed.toJson(), {'theme': 'dark', 'name': 'declared'});
  });

  test('custom capture fields honor the configured case style', () {
    final model = CaseStyledExtrasSchema.parse({
      'display_name': 'Ada',
      'theme': 'dark',
    });
    expect(model.extraValues, {'theme': 'dark'});
    expect(model.toJson(), {'theme': 'dark', 'display_name': 'Ada'});
  });

  test('discard accepts extras without storing them', () {
    final loose = LooseSchema.parse({'name': 'n', 'extra': true});
    expect(loose.toJson(), {'name': 'n'});
    expect(
      () => ProfileSchema.parse({
        'name': 'Ada',
        'nickname': null,
        'tags': ['schema'],
        'color': '#fff',
        'extra': true,
      }),
      throwsA(anything),
    );
  });

  test('copyWith treats null as retain and equality is deep', () {
    final profile = Profile.fromJson({
      'name': 'Ada',
      'nickname': null,
      'tags': ['schema', 'dart'],
      'color': '#fff',
    });
    final renamed = profile.copyWith(name: 'Grace');
    expect(renamed.name, 'Grace');
    expect(renamed.role, 'member');
    expect(renamed.tags, {'schema', 'dart'});
    expect(profile.copyWith(), profile);
    expect(profile.hashCode, profile.copyWith().hashCode);
    expect(
      Profile.fromJson({
        'name': 'Ada',
        'nickname': null,
        'tags': ['schema', 'dart'],
        'color': '#fff',
      }),
      profile,
    );
  });

  test('sealed unions use super parameters and discriminator rules', () {
    final cat = PetSchema.parse({'type': 'cat', 'id': 'c1', 'lives': 9});
    expect(cat, isA<Cat>());
    expect(cat.toJson(), {'type': 'cat', 'id': 'c1', 'lives': 9});
    final dog = PetSchema.parse({'type': 'Dog', 'id': 'd1', 'breed': 'lab'});
    expect(dog, isA<Dog>());
    expect(dog.toJson(), {'type': 'Dog', 'id': 'd1', 'breed': 'lab'});
    expect((cat as Cat).copyWith(lives: 8).id, 'c1');
    final direct = CatSchema.parse({'id': 'c2', 'lives': 7});
    expect(direct.toJson(), {'type': 'cat', 'id': 'c2', 'lives': 7});
    expect(PetSchema.safeParse({'id': 'c2', 'lives': 7}).isFail, isTrue);
  });

  test('prefixed same-named imported types preserve identity', () {
    final pair = ImportedPairSchema.parse({'left': 'a', 'right': 2});
    expect(pair.left, isA<alpha.Item>());
    expect(pair.right, isA<beta.Item>());
    expect(pair.toJson(), {'left': 'a', 'right': 2});
  });

  test('class-first, schema-first, and plain JSON coexist', () {
    expect(Legacy.parse({'enabled': true}).enabled, isTrue);
    final plain = PlainJson.fromJson({'value': 'plain'});
    expect(plain.toJson(), {'value': 'plain'});
  });
}
''');

        _expectSuccess(await _run(temporary, ['pub', 'get']), 'dart pub get');
        _expectSuccess(
          await _run(temporary, ['run', 'build_runner', 'build']),
          'build_runner build',
        );
        final generated = _generatedFiles(temporary);
        expect(
          generated.keys,
          containsAll(['lib/models.ack.dart', 'lib/models.g.dart']),
        );
        expect(
          generated['lib/models.g.dart'],
          contains('_ackProfileFromRuntimeName'),
        );
        expect(
          generated['lib/models.g.dart'],
          contains(r'_$PlainJsonFromJson'),
        );
        expect(generated['lib/models.ack.dart'], contains('class Legacy'));
        expect(
          generated['lib/models.ack.dart'],
          contains(r'mixin _$ProfileAck'),
        );
        expect(
          generated['lib/models.ack.dart'],
          contains('abstract final class ProfileSchema'),
        );
        expect(
          generated['lib/models.ack.dart'],
          contains('final _profileSchema'),
        );
        expect(
          generated['lib/models.ack.dart'],
          isNot(contains('final profileSchema =')),
        );

        _expectSuccess(
          await _run(temporary, ['analyze', '--fatal-infos']),
          'dart analyze --fatal-infos',
        );
        _expectSuccess(await _run(temporary, ['test']), 'dart test');
        _expectSuccess(
          await _run(temporary, ['run', 'build_runner', 'build']),
          'outputs-present build_runner build',
        );
        expect(_generatedFiles(temporary), generated);
      } finally {
        temporary.deleteSync(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
