import 'package:ack_generator/src/builder.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

Future<void> _expectFailure(
  String body,
  List<String> messages, {
  String head = _head,
}) async {
  final readerWriter = TestReaderWriter(rootPackage: 'test_pkg');
  await readerWriter.testing.loadIsolateSources();
  final seen = <String>{};
  await testBuilder(
    ackGenerator(BuilderOptions.empty),
    {'test_pkg|lib/model.dart': '$head\n$body'},
    generateFor: const {'test_pkg|lib/model.dart'},
    readerWriter: readerWriter,
    outputs: const {},
    onLog: (LogRecord log) {
      if (log.level.name != 'SEVERE') return;
      for (final message in messages) {
        if (log.message.contains(message)) seen.add(message);
      }
    },
  );
  expect(seen, containsAll(messages));
}

const _head = '''
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model.ack.dart';
part 'model.g.dart';
''';

void main() {
  test('rejects numeric sugar on a String field', () async {
    await _expectFailure(
      '''
@AckModel()
final class User {
  const User({required this.name});

  @Min(1)
  final String name;
}
''',
      ['@Min', 'String', '@MinLength'],
    );
  });

  test('rejects string sugar on a numeric field', () async {
    await _expectFailure(
      '''
@AckModel()
final class User {
  const User({required this.age});

  @MinLength(1)
  final int age;
}
''',
      ['@MinLength', 'int', '@Min'],
    );
  });

  test('rejects collection sugar on a scalar field', () async {
    await _expectFailure(
      '''
@AckModel()
final class User {
  const User({required this.name});

  @UniqueItems()
  final String name;
}
''',
      ['@UniqueItems', 'String', 'List or Set'],
    );
  });

  test('rejects a static-method AckField escape hatch', () async {
    await _expectFailure(
      '''
final class Schemas {
  static AckSchema<String, String> name() => Ack.string();
}

@AckModel()
final class User {
  const User({required this.name});

  @AckField(schema: Schemas.name)
  final String name;
}
''',
      ['@AckField', 'top-level', 'name'],
    );
  });

  test('rejects an AckField function that does not return AckSchema', () async {
    await _expectFailure(
      '''
String nameSchema() => 'not a schema';

@AckModel()
final class User {
  const User({required this.name});

  @AckField(schema: nameSchema)
  final String name;
}
''',
      ['@AckField', 'AckSchema', 'name'],
    );
  });

  test('requires AckField for Map<String, V>', () async {
    await _expectFailure(
      '''
@AckModel()
final class Stats {
  const Stats({required this.scores});

  final Map<String, int> scores;
}
''',
      ['Stats.scores', 'Map<String, V>', '@AckField'],
    );
  });

  test('rejects non-String map keys', () async {
    await _expectFailure(
      '''
@AckModel()
final class Stats {
  const Stats({required this.scores});

  final Map<int, String> scores;
}
''',
      ['Stats.scores', 'Map<String, V>', 'Map<int, String>'],
    );
  });

  for (final unsupported in ['dynamic', 'Object?']) {
    test('rejects $unsupported fields without a static contract', () async {
      await _expectFailure(
        '''
@AckModel()
final class Payload {
  const Payload({required this.value});

  final $unsupported value;
}
''',
        ['Payload.value', unsupported, 'concrete type'],
      );
    });
  }

  test('rejects private annotated classes', () async {
    await _expectFailure(
      '''
@AckModel()
final class _User {
  const _User({required this.name});

  final String name;
}
''',
      ['_User', 'public class'],
    );
  });

  test('rejects private constructor-backed fields', () async {
    await _expectFailure(
      '''
@AckModel()
final class User {
  const User({required this._secret});

  final String _secret;
}
''',
      ['User._secret', 'private'],
    );
  });

  test('requires the additionalProperties field when enabled', () async {
    await _expectFailure(
      '''
@AckModel(additionalProperties: true)
final class Config {
  const Config({required this.name});

  final String name;
}
''',
      ['Config.additionalProperties', 'Map<String, Object?>'],
    );
  });

  test('requires the exact additionalProperties field type', () async {
    await _expectFailure(
      '''
@AckModel(additionalProperties: true)
final class Config {
  const Config({required this.additionalProperties});

  final Map<String, Object> additionalProperties;
}
''',
      ['Config.additionalProperties', 'Map<String, Object?>'],
    );
  });

  test('requires discriminatorKey on annotated sealed classes', () async {
    await _expectFailure(
      '''
@AckModel()
sealed class Pet {
  const Pet();
}

final class Cat extends Pet {
  const Cat();
}
''',
      ['Pet', 'discriminatorKey'],
    );
  });

  test('rejects duplicate branch discriminator values', () async {
    await _expectFailure(
      '''
@AckModel(discriminatorKey: 'type')
sealed class Pet {
  const Pet();
}

@AckModel(discriminatorValue: 'pet')
final class Cat extends Pet {
  const Cat();
}

@AckModel(discriminatorValue: 'pet')
final class Dog extends Pet {
  const Dog();
}
''',
      ['Pet', 'duplicate discriminatorValue', 'pet'],
    );
  });

  test('rejects abstract intermediate union branches', () async {
    await _expectFailure(
      '''
@AckModel(discriminatorKey: 'type')
sealed class Pet {
  const Pet();
}

abstract base class Mammal extends Pet {
  const Mammal();
}

final class Cat extends Mammal {
  const Cat();
}
''',
      ['Mammal', 'abstract intermediate'],
    );
  });

  test('rejects wrong-typed declared discriminator members', () async {
    await _expectFailure(
      '''
@AckModel(discriminatorKey: 'type')
sealed class Pet {
  const Pet();
}

final class Cat extends Pet {
  const Cat();

  int get type => 1;
}
''',
      ['Cat.type', 'String'],
    );
  });

  test('rejects mismatched literal discriminator members', () async {
    await _expectFailure(
      '''
@AckModel(discriminatorKey: 'type')
sealed class Pet {
  const Pet();
}

@AckModel(discriminatorValue: 'cat')
final class Cat extends Pet {
  const Cat();

  String get type => 'dog';
}
''',
      ['Cat.type', 'cat', 'literal'],
    );
  });

  test('rejects AckModel and JsonSerializable on the same class', () async {
    await _expectFailure(
      '''
@AckModel()
@JsonSerializable()
final class User {
  const User({required this.name});

  final String name;
}
''',
      ['User', '@AckModel', '@JsonSerializable'],
    );
  });

  test('requires the schema-model extension to be visible', () async {
    await _expectFailure(
      '''
@AckModel()
final class User {
  const User();
}
''',
      ['AckSchemaModelExtension', 'visible'],
      head: '''
import 'package:ack/ack.dart'
    show Ack, AckSchema, AckSchemaModel, SchemaResult;
import 'package:ack_annotations/ack_annotations.dart';

part 'model.ack.dart';
part 'model.g.dart';
''',
    );
  });

  test('rejects duplicate generated schema names', () async {
    await _expectFailure(
      '''
@AckModel(schemaName: 'PersonSchema')
final class User {
  const User();
}

@AckModel(schemaName: 'PersonSchema')
final class Admin {
  const Admin();
}
''',
      ['PersonSchema', 'conflicts'],
    );
  });

  test('rejects a lower-camel schema facade override', () async {
    await _expectFailure(
      '''
@AckModel(schemaName: 'personSchema')
final class User {
  const User();
}
''',
      ['personSchema', 'UpperCamel', 'facade'],
    );
  });

  test('rejects a local schema facade collision', () async {
    await _expectFailure(
      '''
@AckModel()
final class User {
  const User();
}

abstract final class UserSchema {}
''',
      ['UserSchema', 'conflicts'],
    );
  });

  test('rejects a local private backing schema collision', () async {
    await _expectFailure(
      '''
@AckModel()
final class User {
  const User();
}

final _userSchema = Ack.string();
''',
      ['_userSchema', 'conflicts'],
    );
  });

  test('rejects an implicit union branch facade collision', () async {
    await _expectFailure(
      '''
@AckModel(discriminatorKey: 'type')
sealed class Pet {
  const Pet();
}

final class Cat extends Pet {
  const Cat();
}

abstract final class CatSchema {}
''',
      ['CatSchema', 'conflicts'],
    );
  });

  for (final collision in <({String name, String declaration})>[
    (
      name: r'_$UserFromRuntime',
      declaration:
          r'User _$UserFromRuntime(Map<String, Object?> value) => throw 0;',
    ),
    (
      name: r'_$UserToRuntime',
      declaration:
          r'Map<String, Object?> _$UserToRuntime(User value) => throw 0;',
    ),
    (
      name: '_ackUserFromRuntimeName',
      declaration: 'String _ackUserFromRuntimeName(Object? value) => "";',
    ),
    (
      name: '_ackUserToRuntimeName',
      declaration: 'Object? _ackUserToRuntimeName(String value) => value;',
    ),
    (
      name: r'_$UserFromJson',
      declaration:
          r'User _$UserFromJson(Map<String, dynamic> value) => throw 0;',
    ),
    (
      name: r'_$UserToJson',
      declaration: r'Map<String, dynamic> _$UserToJson(User value) => throw 0;',
    ),
    (name: 'UserAck', declaration: 'extension UserAck on User {}'),
  ]) {
    test('rejects local ${collision.name} helper collisions', () async {
      await _expectFailure(
        '''
@AckModel()
final class User {
  const User({required this.name});

  final String name;
}

${collision.declaration}
''',
        [collision.name, 'conflicts'],
      );
    });
  }

  test('rejects a local raw union object helper collision', () async {
    await _expectFailure(
      '''
@AckModel(discriminatorKey: 'type')
sealed class Pet {
  const Pet();
}

final class Cat extends Pet {
  const Cat();
}

final _catObject = Ack.object({});
''',
      ['_catObject', 'conflicts'],
    );
  });

  test('rejects case-only branch backing schema collisions', () async {
    await _expectFailure(
      '''
@AckModel(discriminatorKey: 'type')
sealed class Pet {
  const Pet();
}

@AckModel(schemaName: 'UpperCatSchema')
final class Cat extends Pet {
  const Cat();
}

@AckModel(schemaName: 'LowerCatSchema')
final class cat extends Pet {
  const cat();
}
''',
      ['_catSchema', 'conflicts'],
    );
  });

  test('rejects case-style key collisions', () async {
    await _expectFailure(
      '''
@AckModel(caseStyle: AckCaseStyle.snake)
final class Collision {
  const Collision({required this.fooBar, required this.foo_bar});

  final String fooBar;
  final String foo_bar;
}
''',
      ['Collision.foo_bar', 'foo_bar', 'JSON key'],
    );
  });
}
