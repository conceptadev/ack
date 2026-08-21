import 'package:ack_generator/src/builder.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

Future<void> _expectOutput(String source, Matcher matcher) async {
  final readerWriter = TestReaderWriter(rootPackage: 'test_pkg');
  await readerWriter.testing.loadIsolateSources();
  await testBuilder(
    ackGenerator(BuilderOptions.empty),
    {'test_pkg|lib/schema.dart': source},
    generateFor: const {'test_pkg|lib/schema.dart'},
    readerWriter: readerWriter,
    outputs: {'test_pkg|lib/schema.ack.dart': decodedMatches(matcher)},
  );
}

Future<void> _expectFailure(String source, List<String> messages) async {
  final readerWriter = TestReaderWriter(rootPackage: 'test_pkg');
  await readerWriter.testing.loadIsolateSources();
  final seen = <String>{};
  await testBuilder(
    ackGenerator(BuilderOptions.empty),
    {'test_pkg|lib/schema.dart': source},
    generateFor: const {'test_pkg|lib/schema.dart'},
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

part 'schema.ack.dart';
part 'schema.g.dart';
''';

void main() {
  test(
    'models custom bidirectional codecs from generic schema types',
    () async {
      await _expectOutput(
        '''
$_head
final class UserId {
  const UserId(this.value);
  final int value;
}

final class TagList {
  const TagList(this.values);
  final List<String> values;
}

@AckType(name: 'UserIdModel')
final userIdSchema = Ack.integer().codec<UserId>(
  decode: UserId.new,
  encode: (id) => id.value,
);

@AckType()
final profileSchema = Ack.object({
  'tags': Ack.list(Ack.string()).codec<TagList>(
    decode: TagList.new,
    encode: (tags) => tags.values,
  ),
});
''',
        allOf([
          contains('final class UserIdModel'),
          contains('final UserId value;'),
          contains('factory UserIdModel.fromJson(int json)'),
          contains('int toJson()'),
          contains('required this.tags'),
        ]),
      );
    },
  );

  test('treats object roots with an outer codec as value models', () async {
    await _expectOutput(
      '''
$_head
final class UserRecord {
  const UserRecord(this.name);
  final String name;
}

@AckType()
final userSchema = Ack.object({
  'name': Ack.string(),
}).codec<UserRecord>(
  decode: (value) => UserRecord(value['name'] as String),
  encode: (user) => {'name': user.name},
);
''',
      allOf([
        contains('final class User'),
        contains('User(this.value)'),
        contains('final UserRecord value;'),
        contains('factory User.fromJson(Map<String, Object?> json)'),
        contains('Map<String, Object?> toJson()'),
      ]),
    );
  });

  test('resolves named lazy self recursion through model adapters', () async {
    await _expectOutput(
      '''
$_head
@AckType()
final AckSchema<JsonMap, JsonMap> nodeSchema = Ack.object({
  'name': Ack.string(),
  'children': Ack.list(
    Ack.lazy('node', () => nodeSchema),
  ),
});
''',
      allOf([
        contains('final List<Node> children;'),
        contains(r'Node.$ack.fromRuntime'),
        contains(r'Node.$ack.toRuntime'),
      ]),
    );
  });

  test('models mutually recursive lazy schemas', () async {
    await _expectOutput(
      '''
$_head
@AckType()
final AckSchema<JsonMap, JsonMap> authorSchema = Ack.object({
  'books': Ack.list(Ack.lazy('book', () => bookSchema)),
});

@AckType()
final AckSchema<JsonMap, JsonMap> bookSchema = Ack.object({
  'author': Ack.lazy('author', () => authorSchema),
});
''',
      allOf([
        contains('final List<Book> books;'),
        contains('final Author author;'),
      ]),
    );
  });

  test('rejects unsupported dynamic roots with the declaration path', () async {
    await _expectFailure(
      '''
$_head
@AckType()
final payloadSchema = Ack.any();
''',
      ['payloadSchema', 'Ack.any()'],
    );
  });

  for (final unsupported in {
    'Ack.anyOf([Ack.string(), Ack.integer()])': 'Ack.anyOf()',
    'Ack.instance<Object>()': 'bare Ack.instance<T>()',
    'Ack.string().nullable()': 'nullable root',
  }.entries) {
    test('rejects unsupported root ${unsupported.key}', () async {
      await _expectFailure(
        '''
$_head
@AckType()
final payloadSchema = ${unsupported.key};
''',
        [unsupported.value],
      );
    });
  }

  test('rejects ordinary alias cycles', () async {
    await _expectFailure(
      '''
$_head
@AckType()
final firstSchema = secondSchema;

@AckType()
final secondSchema = firstSchema;
''',
      ['alias cycle', 'firstSchema'],
    );
  });
}
