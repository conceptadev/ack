// Modern schema-first runtime integration tests.
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

void main() {
  test(
    'clean generated models compile and preserve the AckInfer runtime contract',
    () async {
      var projectRoot = Directory.current;
      while (!Directory(
        p.join(projectRoot.path, 'packages', 'ack_generator'),
      ).existsSync()) {
        projectRoot = projectRoot.parent;
      }
      final temporary = await Directory.systemTemp.createTemp(
        'ack_ack_infer_runtime_',
      );
      try {
        Directory(p.join(temporary.path, 'lib')).createSync();
        Directory(p.join(temporary.path, 'test')).createSync();
        File(p.join(temporary.path, 'pubspec.yaml')).writeAsStringSync('''
name: ack_ack_infer_runtime
publish_to: none
environment:
  sdk: '>=3.9.0 <4.0.0'
dependencies:
  ack:
    path: ${p.join(projectRoot.path, 'packages', 'ack')}
  ack_annotations:
    path: ${p.join(projectRoot.path, 'packages', 'ack_annotations')}
dev_dependencies:
  ack_generator:
    path: ${p.join(projectRoot.path, 'packages', 'ack_generator')}
  build_runner: ^2.15.0
  test: ^1.29.0
dependency_overrides:
  ack:
    path: ${p.join(projectRoot.path, 'packages', 'ack')}
  ack_annotations:
    path: ${p.join(projectRoot.path, 'packages', 'ack_annotations')}
''');
        File(p.join(temporary.path, 'lib', 'models.dart')).writeAsStringSync(
          r'''
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

part 'models.ack.dart';
part 'models.ack.g.dart';

final class Box {
  const Box(this.values);
  final List<String> values;
}

final class RuntimeUser {
  const RuntimeUser(this.name);
  final String name;
}

@AckInfer(name: 'UserRecord')
final userRecordSchema = Ack.object({
  'name': Ack.string(),
}).codec<RuntimeUser>(
  decode: (value) => RuntimeUser(value['name'] as String),
  encode: (user) => {'name': user.name},
);

@AckInfer()
final AckSchema<JsonMap, JsonMap> nodeSchema = Ack.object({
  'label': Ack.string(),
  'children': Ack.list(
    Ack.lazy('node', () => nodeSchema),
  ).optional(),
});

@AckInfer()
final AckSchema<JsonMap, JsonMap> authorSchema = Ack.object({
  'books': Ack.list(Ack.lazy('book', () => bookSchema)),
});

@AckInfer()
final AckSchema<JsonMap, JsonMap> bookSchema = Ack.object({
  'title': Ack.string(),
  'author': Ack.lazy('author', () => authorSchema).optional(),
});

@AckInfer()
final extrasSchema = Ack.object({
  'name': Ack.string(),
  'maybe': Ack.string().nullable(),
  'nickname': Ack.string().optional(),
  'role': Ack.string().withDefault('member'),
  'numbers': Ack.list(Ack.list(Ack.integer())),
  'box': Ack.list(Ack.string()).codec<Box>(
    decode: Box.new,
    encode: (box) => box.values,
  ),
}).passthrough();

@AckInfer()
final catSchema = Ack.object({'lives': Ack.integer()});

@AckInfer()
final dogSchema = Ack.object({'friendly': Ack.boolean()}).passthrough();

@AckInfer()
final petSchema = Ack.discriminated(
  discriminatorKey: 'kind',
  schemas: {'cat': catSchema, 'dog': dogSchema},
);

@AckInfer(name: 'MemberType')
final memberSchema = Ack.string();

@AckInfer()
final emptySchema = Ack.object({});

@AckInfer()
final scoresSchema = Ack.list(Ack.integer());

final class Counted {
  Counted(this.value);
  final String value;
  static var decodes = 0;
  static var encodes = 0;
  static Counted decode(String value) {
    decodes += 1;
    return Counted(value);
  }
  static String encode(Counted value) {
    encodes += 1;
    return value.value;
  }
}

@AckInfer(name: 'CountedModel')
final countedSchema = Ack.object({
  'item': Ack.string().codec<Counted>(
    decode: Counted.decode,
    encode: Counted.encode,
  ),
  'items': Ack.list(
    Ack.string().codec<Counted>(
      decode: Counted.decode,
      encode: Counted.encode,
    ),
  ),
});
''',
        );
        File(p.join(temporary.path, 'lib', 'address.dart')).writeAsStringSync(
          r'''
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

part 'address.ack.dart';
part 'address.ack.g.dart';

@AckInfer()
final addressSchema = Ack.object({'city': Ack.string()});
''',
        );
        File(
          p.join(temporary.path, 'lib', 'exports.dart'),
        ).writeAsStringSync("export 'address.dart';\n");
        File(p.join(temporary.path, 'lib', 'person.dart')).writeAsStringSync(
          r'''
import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

import 'address.dart' as direct;
import 'exports.dart' as exported;

part 'person.ack.dart';
part 'person.ack.g.dart';

@AckInfer()
final personSchema = Ack.object({
  'home': direct.addressSchema,
  'history': Ack.list(exported.addressSchema),
});
''',
        );
        File(
          p.join(temporary.path, 'test', 'runtime_test.dart'),
        ).writeAsStringSync(r'''
import 'package:ack_ack_infer_runtime/models.dart';
import 'package:ack_ack_infer_runtime/person.dart';
import 'package:test/test.dart';

void main() {
  test('recursion and imported model references round-trip', () {
    final node = Node.parse({
      'label': 'root',
      'children': [
        {'label': 'leaf'},
      ],
    });
    expect(node.children!.single, isA<Node>());
    expect(node.toJson(), {
      'label': 'root',
      'children': [
        {'label': 'leaf'},
      ],
    });
    expect(() => node.children!.add(Node(label: 'other')), throwsUnsupportedError);

    final author = Author.parse({
      'books': [
        {'title': 'Ack'},
      ],
    });
    expect(author.books.single, isA<Book>());
    expect(author.books.single.author, isNull);

    final person = Person.parse({
      'home': {'city': 'New York'},
      'history': [
        {'city': 'Amsterdam'},
      ],
    });
    expect(person.home.city, 'New York');
    expect(person.history.single.city, 'Amsterdam');
  });

  test('field semantics, codecs, and recursive immutability hold', () {
    final extras = Extras.parse({
      'name': 'Ada',
      'maybe': null,
      'numbers': [
        [1, 2],
      ],
      'box': ['a', 'b'],
      'dynamic': {
        'items': [1, 2],
      },
    });
    expect(extras.role, 'member');
    expect(extras.nickname, isNull);
    expect(extras.box.values, ['a', 'b']);
    expect(() => extras.numbers.single.add(3), throwsUnsupportedError);
    final dynamic = extras.additionalProperties['dynamic']! as Map;
    expect(() => (dynamic['items']! as List).add(3), throwsUnsupportedError);

    final constructed = Extras(
      name: 'declared',
      maybe: null,
      role: 'member',
      numbers: const [
        [1],
      ],
      box: const Box(['x']),
      additionalProperties: const {
        'name': 'extra',
        'nickname': 'injected',
        'maybe': 'spoofed',
      },
    );
    expect(constructed.additionalProperties, {
      'name': 'extra',
      'nickname': 'injected',
      'maybe': 'spoofed',
    });
    expect(constructed.toJson()['name'], 'declared');
    expect(constructed.toJson().containsKey('nickname'), isFalse);
    expect(constructed.toJson()['maybe'], isNull);
    expect(constructed.toJson().containsKey('maybe'), isTrue);
  });

  test('union discriminators cannot be spoofed through extras', () {
    final dog = Dog(
      friendly: true,
      additionalProperties: const {'kind': 'cat', 'lives': 9},
    );
    expect(dog.additionalProperties['kind'], 'cat');
    expect(dog.toJson(), {'lives': 9, 'kind': 'dog', 'friendly': true});
  });

  test('unions and exact value-root names round-trip', () {
    final pet = Pet.parse({'kind': 'cat', 'lives': 9});
    expect(pet, isA<Cat>());
    expect(pet.toJson(), {'kind': 'cat', 'lives': 9});

    final member = MemberType.parse('admin');
    expect(member.value, 'admin');
    expect(member.toJson(), 'admin');

    final user = UserRecord.parse({'name': 'Ada'});
    expect(user.value.name, 'Ada');
    expect(user.toJson(), {'name': 'Ada'});

    expect(Empty.parse({}).toJson(), isEmpty);
    final scores = Scores.parse([1, 2]);
    expect(scores.value, [1, 2]);
    expect(scores.toJson(), [1, 2]);
    expect(() => scores.value.add(3), throwsUnsupportedError);

    Counted.decodes = 0;
    Counted.encodes = 0;
    final counted = CountedModel.parse({
      'item': 'a',
      'items': ['b', 'c'],
    });
    expect(Counted.decodes, 3);
    expect(counted.item.value, 'a');
    expect(counted.items.map((item) => item.value), ['b', 'c']);
    expect(counted.toJson(), {
      'item': 'a',
      'items': ['b', 'c'],
    });
    expect(Counted.encodes, 3);
    expect(Counted.decodes, 3);
  });
}
''');

        _expectSuccess(await _run(temporary, ['pub', 'get']), 'dart pub get');
        _expectSuccess(
          await _run(temporary, ['run', 'build_runner', 'build']),
          'build_runner build',
        );

        final generated = {
          for (final file
              in temporary
                  .listSync(recursive: true)
                  .whereType<File>()
                  .where(
                    (file) =>
                        file.path.endsWith('.ack.dart') ||
                        file.path.endsWith('.ack.g.dart'),
                  ))
            p.relative(file.path, from: temporary.path): file
                .readAsStringSync(),
        };
        expect(
          generated.keys,
          containsAll(['lib/models.ack.dart', 'lib/models.ack.g.dart']),
        );
        expect(
          generated['lib/models.ack.g.dart'],
          contains(r'_$ExtrasFromJson'),
        );
        expect(
          generated['lib/models.ack.g.dart'],
          contains('Extras._ackFromRuntimeName'),
        );
        expect(generated['lib/models.ack.dart'], contains(r'_$ExtrasFromJson'));

        _expectSuccess(
          await _run(temporary, ['analyze', '--fatal-infos']),
          'dart analyze --fatal-infos',
        );
        _expectSuccess(await _run(temporary, ['test']), 'dart test');
        _expectSuccess(
          await _run(temporary, ['run', 'build_runner', 'build']),
          'second build_runner build',
        );
        final rebuilt = {
          for (final file
              in temporary
                  .listSync(recursive: true)
                  .whereType<File>()
                  .where(
                    (file) =>
                        file.path.endsWith('.ack.dart') ||
                        file.path.endsWith('.ack.g.dart'),
                  ))
            p.relative(file.path, from: temporary.path): file
                .readAsStringSync(),
        };
        expect(rebuilt, generated);
      } finally {
        temporary.deleteSync(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
