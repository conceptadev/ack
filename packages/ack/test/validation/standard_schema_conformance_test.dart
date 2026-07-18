import 'package:ack/ack.dart';
import 'package:standard_schema/utils.dart';
import 'package:test/test.dart';

enum _Role { admin, member }

final class _Animal {
  const _Animal(this.kind);

  final String kind;
}

final class _MinimumIntConstraint extends Constraint<int>
    with Validator<int>, JsonSchemaSpec<int> {
  const _MinimumIntConstraint()
    : super(constraintKey: 'minimum_int', description: 'At least 1.');

  @override
  bool isValid(int value) => value >= 1;

  @override
  String buildMessage(int value) => 'Expected at least 1.';

  @override
  Map<String, Object?> toJsonSchema() => const {'minimum': 1};
}

const _draft7Options = StandardJsonSchemaOptions(
  target: JsonSchemaTarget.draft07,
);

CodecSchema<String, int> _stringToIntCodec() {
  return Ack.codec<String, String, int>(
    input: Ack.string(),
    decode: int.parse,
    encode: (value) => value.toString(),
    output: Ack.integer(),
  );
}

void main() {
  group('Ack Standard Schema conformance', () {
    test('exposes the Standard Schema contract through package:ack', () async {
      final schema = Ack.string();

      expect(schema, isA<StandardSchemaWithJsonSchema<Object?, String?>>());
      expect(schema.standard.vendor, 'ack');
      expect(schema.standard.version, 1);

      final result = await Future.value(schema.standard.validate('Ada'));

      expect(result, isA<StandardSuccess<String?>>());
      expect((result as StandardSuccess<String?>).value, 'Ada');
    });

    test('maps nested Ack failures to flat Standard issues', () async {
      final schema = Ack.object({
        'user': Ack.object({'tags': Ack.list(Ack.string())}),
      });

      final result = await Future.value(
        schema.standard.validate({
          'user': {
            'tags': ['ok', 1],
          },
        }),
      );

      expect(result, isA<StandardFailure<JsonMap?>>());
      final failure = result as StandardFailure<JsonMap?>;

      expect(failure.issues, hasLength(1));
      expect(failure.issues.single.path, ['user', 'tags', 1]);
      expect(getDotPath(failure.issues.single), 'user.tags.1');
      expect(failure.issues.single.message, contains('Expected string'));
    });

    test('maps constraint failures to individual Standard issues', () async {
      final schema = Ack.string().minLength(3);

      final result = await Future.value(schema.standard.validate('a'));

      expect(result, isA<StandardFailure<String?>>());
      final failure = result as StandardFailure<String?>;

      expect(failure.issues, hasLength(1));
      expect(failure.issues.single.path, isEmpty);
      expect(failure.issues.single.message, contains('Minimum 3'));
    });

    test('fans out every failing constraint into its own issue', () async {
      final schema = Ack.string().minLength(5).matches(r'^\d+$');

      final result = await Future.value(schema.standard.validate('ab'));

      final failure = result as StandardFailure<String?>;
      expect(failure.issues, hasLength(2));
      expect(failure.issues.map((i) => i.path), everyElement(isEmpty));
      expect(
        failure.issues.map((i) => i.message),
        containsAll([contains('Minimum 5'), contains('match')]),
      );
    });

    test(
      'fans out sibling object field failures into distinct paths',
      () async {
        final schema = Ack.object({'a': Ack.string(), 'b': Ack.integer()});

        final result = await Future.value(
          schema.standard.validate({'a': 1, 'b': 'x'}),
        );

        final failure = result as StandardFailure<JsonMap?>;
        expect(failure.issues, hasLength(2));
        expect(
          failure.issues.map((i) => i.path),
          containsAll([
            ['a'],
            ['b'],
          ]),
        );
      },
    );

    test('fans out sibling list item failures into indexed paths', () async {
      final schema = Ack.list(Ack.string());

      final result = await Future.value(schema.standard.validate([1, 'ok', 2]));

      final failure = result as StandardFailure<List<String>?>;
      expect(failure.issues, hasLength(2));
      expect(
        failure.issues.map((i) => i.path),
        containsAll([
          [0],
          [2],
        ]),
      );
    });

    test('converts Draft-7 input JSON Schema through AckSchemaModel', () {
      final schema = Ack.object({
        'name': Ack.string(),
        'roles': Ack.list(Ack.enumValues(_Role.values)),
      });

      expect(
        schema.standard.jsonSchema.input(_draft7Options),
        schema.toJsonSchema(),
      );
    });

    test('models valid defaults as nullable Standard input only', () {
      final schema = Ack.integer().withDefault(7);

      expect(schema.standard.validate(null), isA<StandardSuccess<int?>>());
      expect(schema.toJsonSchema(), {'type': 'integer', 'default': 7});
      expect(schema.standard.jsonSchema.input(_draft7Options), {
        'default': 7,
        'anyOf': [
          {'type': 'integer'},
          {'type': 'null'},
        ],
      });
    });

    test('keeps invalid defaults out of the Standard input domain', () {
      final schema = Ack.integer().min(10).withDefault(5);

      expect(schema.standard.validate(null), isA<StandardFailure<int?>>());
      expect(schema.standard.jsonSchema.input(_draft7Options), {
        'type': 'integer',
        'minimum': 10,
      });
    });

    test('resolves each default once per Standard conversion', () {
      var validations = 0;
      final schema = Ack.object({
        'count': Ack.string()
            .transform<int>(int.parse)
            .refine((value) {
              validations++;
              return true;
            })
            .withDefault(7),
      });

      schema.standard.jsonSchema.input(_draft7Options);

      expect(validations, 1);
    });

    test('does not leak codec runtime constraints into input schemas', () {
      final schema = _stringToIntCodec().withConstraint(
        const _MinimumIntConstraint(),
      );

      expect(schema.standard.jsonSchema.input(_draft7Options), {
        'type': 'string',
        'x-transformed': true,
      });
      expect(schema.standard.jsonSchema.output(_draft7Options), {
        'type': 'integer',
        'minimum': 1,
      });
    });

    test('uses codec null policy instead of nested schema nullability', () {
      final schema = Ack.string()
          .nullable()
          .codec<int>(
            decode: int.parse,
            encode: (value) => value.toString(),
            output: Ack.integer().nullable(),
          )
          .nullable(value: false);

      expect(schema.standard.validate(null), isA<StandardFailure<int?>>());
      expect(schema.standard.jsonSchema.input(_draft7Options), {
        'type': 'string',
        'x-transformed': true,
      });
      expect(schema.standard.jsonSchema.output(_draft7Options), {
        'type': 'integer',
      });
    });

    test('rejects bare instance Standard input schemas', () {
      final schema = Ack.instance<_Animal>();

      expect(
        () => schema.standard.jsonSchema.input(_draft7Options),
        throwsUnsupportedError,
      );
      expect(schema.toSchemaModel().warnings, isNotEmpty);
    });

    test('rejects passthrough object Standard JSON Schemas', () {
      final schema = Ack.object(const {}, additionalProperties: true);
      final result = schema.standard.validate({
        'createdAt': DateTime.utc(2026),
      });

      expect(result, isA<StandardSuccess<JsonMap?>>());
      expect(
        () => schema.standard.jsonSchema.input(_draft7Options),
        throwsUnsupportedError,
      );
      expect(
        () => schema.standard.jsonSchema.output(_draft7Options),
        throwsUnsupportedError,
      );
    });

    test('throws for enum runtime output schemas', () {
      final schema = Ack.enumValues(_Role.values);

      expect(
        () => schema.standard.jsonSchema.output(_draft7Options),
        throwsUnsupportedError,
      );
    });

    test('throws for unsupported JSON Schema targets', () {
      final schema = Ack.string();

      expect(
        () => schema.standard.jsonSchema.input(
          const StandardJsonSchemaOptions(target: JsonSchemaTarget.openapi30),
        ),
        throwsUnsupportedError,
      );
      expect(
        () => schema.standard.jsonSchema.output(
          const StandardJsonSchemaOptions(target: JsonSchemaTarget.draft202012),
        ),
        throwsUnsupportedError,
      );
    });

    test('uses representable codec output schemas', () {
      final schema = _stringToIntCodec();

      expect(schema.standard.jsonSchema.input(_draft7Options), {
        'type': 'string',
        'x-transformed': true,
      });
      expect(schema.standard.jsonSchema.output(_draft7Options), {
        'type': 'integer',
      });
    });

    test('recursively projects nested codec output schemas', () {
      final stringToInt = _stringToIntCodec();
      final objectSchema = Ack.object({'count': stringToInt});
      final listSchema = Ack.list(stringToInt);

      expect(objectSchema.standard.jsonSchema.output(_draft7Options), {
        'type': 'object',
        'properties': {
          'count': {'type': 'integer'},
        },
        'required': ['count'],
        'additionalProperties': false,
      });
      expect(listSchema.standard.jsonSchema.output(_draft7Options), {
        'type': 'array',
        'items': {'type': 'integer'},
      });
    });

    test(
      'describes defaulted nullable output as the runtime default shape',
      () {
        final schema = Ack.integer().nullable().withDefault(7);

        expect(schema.standard.jsonSchema.output(_draft7Options), {
          'type': 'integer',
          'default': 7,
        });

        final result = schema.standard.validate(null) as StandardSuccess<int?>;
        expect(result.value, 7);
      },
    );

    test(
      'marks materialized defaulted object fields as required on output',
      () {
        final schema = Ack.object({'count': Ack.integer().withDefault(7)});

        expect(schema.standard.jsonSchema.input(_draft7Options), {
          'type': 'object',
          'properties': {
            'count': {
              'default': 7,
              'anyOf': [
                {'type': 'integer'},
                {'type': 'null'},
              ],
            },
          },
          'additionalProperties': false,
        });
        expect(schema.standard.jsonSchema.output(_draft7Options), {
          'type': 'object',
          'properties': {
            'count': {'type': 'integer', 'default': 7},
          },
          'required': ['count'],
          'additionalProperties': false,
        });

        final result =
            schema.standard.validate({}) as StandardSuccess<JsonMap?>;
        expect(result.value, {'count': 7});
      },
    );

    test('preserves representable outer codec output metadata', () {
      final schema = Ack.codec<String, String, int>(
        input: Ack.string(),
        decode: int.parse,
        encode: (value) => value.toString(),
        output: Ack.integer().min(1),
      ).nullable().describe('Parsed count').withDefault(7);

      expect(schema.standard.jsonSchema.output(_draft7Options), {
        'description': 'Parsed count',
        'default': 7,
        'type': 'integer',
        'minimum': 1,
      });
    });

    test('preserves nested defaulted codec output constraints', () {
      final schema = Ack.object({
        'count': Ack.codec<String, String, int>(
          input: Ack.string(),
          decode: int.parse,
          encode: (value) => value.toString(),
          output: Ack.integer().min(1),
        ).nullable().withDefault(7),
      });

      expect(schema.standard.jsonSchema.output(_draft7Options), {
        'type': 'object',
        'properties': {
          'count': {'type': 'integer', 'minimum': 1, 'default': 7},
        },
        'required': ['count'],
        'additionalProperties': false,
      });
    });

    test('throws when anyOf output contains a runtime-only branch', () {
      final schema = Ack.anyOf([Ack.string(), Ack.enumValues(_Role.values)]);

      expect(
        () => schema.standard.jsonSchema.output(_draft7Options),
        throwsUnsupportedError,
      );
    });

    test('exports representable lazy output schemas', () {
      final target = Ack.object({'name': Ack.string()});
      final schema = Ack.lazy<JsonMap, JsonMap>('LazyUser', () => target);

      final output = schema.standard.jsonSchema.output(_draft7Options);
      final definitions = output['definitions']! as Map;

      expect(output['allOf'], [
        {r'$ref': '#/definitions/LazyUser'},
      ]);
      expect(definitions['LazyUser'], {
        'type': 'object',
        'properties': {
          'name': {'type': 'string'},
        },
        'required': ['name'],
        'additionalProperties': false,
      });
    });

    test(
      'throws for lazy output schemas that resolve to runtime-only values',
      () {
        final schema = Ack.lazy<String, _Role>(
          'LazyRole',
          () => Ack.enumValues(_Role.values),
        );

        expect(
          () => schema.standard.jsonSchema.output(_draft7Options),
          throwsUnsupportedError,
        );
      },
    );

    test('throws for transform output schemas that are runtime-only', () {
      final schema = Ack.string().transform<int>(int.parse);

      expect(
        () => schema.standard.jsonSchema.output(_draft7Options),
        throwsUnsupportedError,
      );
    });

    test('throws for codec output schemas that are runtime-only', () {
      final schema = Ack.date();

      expect(
        schema.standard.jsonSchema.input(_draft7Options),
        schema.toJsonSchema(),
      );
      expect(
        () => schema.standard.jsonSchema.output(_draft7Options),
        throwsUnsupportedError,
      );
    });

    test('throws for bare instance runtime output schemas', () {
      final schema = Ack.instance<_Animal>();

      expect(
        () => schema.standard.jsonSchema.output(_draft7Options),
        throwsUnsupportedError,
      );
    });

    test('throws for model-backed discriminated runtime output schemas', () {
      final schema = Ack.discriminated<_Animal>(
        discriminatorKey: 'type',
        schemas: {
          'cat': Ack.object({'name': Ack.string()}).codec<_Animal>(
            decode: (_) => const _Animal('cat'),
            encode: (_) => {'name': 'Milo'},
          ),
        },
      );

      expect(
        () => schema.standard.jsonSchema.output(_draft7Options),
        throwsUnsupportedError,
      );
    });

    test('keeps list indexes numeric under default wrappers', () async {
      final schema = Ack.list(Ack.string()).withDefault(const ['fallback']);

      final result = await Future.value(schema.standard.validate([1]));

      final failure = result as StandardFailure<List<String>?>;
      expect(failure.issues.single.path, [0]);
    });

    test('keeps list indexes numeric under codec wrappers', () async {
      final schema = Ack.list(Ack.string()).codec<List<String>>(
        decode: (value) => value,
        encode: (value) => value,
        output: Ack.list(Ack.string()),
      );

      final result = await Future.value(schema.standard.validate([1]));

      final failure = result as StandardFailure<List<String>?>;
      expect(failure.issues.single.path, [0]);
    });
  });
}
