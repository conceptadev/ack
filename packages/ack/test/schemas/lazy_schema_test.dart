import 'package:ack/ack.dart';
import 'package:test/test.dart';

void main() {
  test('parses and encodes a recursive object graph', () {
    late final ObjectSchema categorySchema;
    categorySchema = Ack.object({
      'name': Ack.string(),
      'children': Ack.list(
        Ack.lazy<JsonMap, JsonMap>('Category', () => categorySchema),
      ),
    });

    final json = <String, Object?>{
      'name': 'root',
      'children': [
        {
          'name': 'first',
          'children': [
            {'name': 'leaf', 'children': <Object?>[]},
          ],
        },
      ],
    };

    final parsed = categorySchema.parse(json);
    expect(parsed, equals(json));

    final encoded = categorySchema.encode(parsed);
    expect(encoded, equals(json));
    expect(categorySchema.encode(categorySchema.parse(json)), equals(json));
  });

  test('exports recursive object graph via definitions and refs', () {
    late final ObjectSchema categorySchema;
    categorySchema = Ack.object({
      'name': Ack.string(),
      'children': Ack.list(
        Ack.lazy<JsonMap, JsonMap>('Category', () => categorySchema),
      ),
    });

    final jsonSchema = categorySchema.toJsonSchema();
    final properties = jsonSchema['properties']! as Map;
    final children = properties['children']! as Map;
    final definitions = jsonSchema['definitions']! as Map;
    final categoryDef = definitions['Category']! as Map;
    final categoryProperties = categoryDef['properties']! as Map;
    final nestedChildren = categoryProperties['children']! as Map;

    expect(children['items'], {r'$ref': '#/definitions/Category'});
    expect(nestedChildren['items'], {r'$ref': '#/definitions/Category'});
    expect(definitions.keys, ['Category']);
  });

  test('deduplicates lazies with the same name and same target', () {
    final target = Ack.object({'name': Ack.string()});
    final first = Ack.lazy<JsonMap, JsonMap>('Category', () => target);
    final second = Ack.lazy<JsonMap, JsonMap>('Category', () => target);
    final schema = Ack.object({'first': first, 'second': second});

    final jsonSchema = schema.toJsonSchema();
    final properties = jsonSchema['properties']! as Map;
    final definitions = jsonSchema['definitions']! as Map;

    expect(definitions.keys, ['Category']);
    expect(properties['first'], {r'$ref': '#/definitions/Category'});
    expect(properties['second'], {r'$ref': '#/definitions/Category'});
  });

  test('escapes lazy names in JSON Pointer refs', () {
    final target = Ack.object({'name': Ack.string()});
    final schema = Ack.object({
      'node': Ack.lazy<JsonMap, JsonMap>('Tree/Node~1', () => target),
    });

    final jsonSchema = schema.toJsonSchema();
    final properties = jsonSchema['properties']! as Map;
    final definitions = jsonSchema['definitions']! as Map;

    expect(definitions.keys, ['Tree/Node~1']);
    expect(properties['node'], {r'$ref': '#/definitions/Tree~1Node~01'});
  });

  test('merges custom root definitions with lazy definitions', () {
    late final AckSchema<JsonMap, JsonMap> categorySchema;
    categorySchema =
        Ack.object({
          'name': Ack.string(),
          'slug': Ack.string(),
          'child': Ack.lazy<JsonMap, JsonMap>('Category', () => categorySchema),
        }).withConstraint(
          const _TestJsonSchemaKeywordConstraint<JsonMap>({
            'definitions': {
              'Slug': {'type': 'string', 'pattern': r'^[a-z0-9-]+$'},
            },
          }),
        );

    final jsonSchema = categorySchema.toJsonSchema();
    final definitions = jsonSchema['definitions']! as Map;

    expect(definitions['Slug'], {'type': 'string', 'pattern': r'^[a-z0-9-]+$'});
    expect(definitions['Category'], isA<Map>());
  });

  test('rejects custom root definitions that collide with lazy names', () {
    late final AckSchema<JsonMap, JsonMap> categorySchema;
    categorySchema =
        Ack.object({
          'name': Ack.string(),
          'child': Ack.lazy<JsonMap, JsonMap>('Category', () => categorySchema),
        }).withConstraint(
          const _TestJsonSchemaKeywordConstraint<JsonMap>({
            'definitions': {
              'Category': {'type': 'string'},
            },
          }),
        );

    expect(
      categorySchema.toJsonSchema,
      throwsA(
        isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          contains('collides with an existing root JSON Schema definition'),
        ),
      ),
    );
  });

  test('rejects lazies with the same name and different targets', () {
    final firstTarget = Ack.object({'name': Ack.string()});
    final secondTarget = Ack.object({'title': Ack.string()});
    final schema = Ack.object({
      'first': Ack.lazy<JsonMap, JsonMap>('Category', () => firstTarget),
      'second': Ack.lazy<JsonMap, JsonMap>('Category', () => secondTarget),
    });

    expect(
      schema.toJsonSchema,
      throwsA(
        isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          contains('share name "Category"'),
        ),
      ),
    );
  });

  test('wraps non-null lazy metadata without ref siblings', () {
    late final ObjectSchema categorySchema;
    categorySchema = Ack.object({
      'name': Ack.string(),
      'child': Ack.lazy<JsonMap, JsonMap>(
        'Category',
        () => categorySchema,
      ).describe('Child category'),
    });

    final jsonSchema = categorySchema.toJsonSchema();
    final properties = jsonSchema['properties']! as Map;

    expect(properties['child'], {
      'description': 'Child category',
      'allOf': [
        {r'$ref': '#/definitions/Category'},
      ],
    });
    expect(properties['child'], isNot(contains(r'$ref')));
  });

  test('exports nullable lazy references with metadata', () {
    late final ObjectSchema categorySchema;
    categorySchema = Ack.object({
      'name': Ack.string(),
      'parent': Ack.lazy<JsonMap, JsonMap>(
        'Category',
        () => categorySchema,
      ).describe('Parent category').nullable(),
    });

    final jsonSchema = categorySchema.toJsonSchema();
    final properties = jsonSchema['properties']! as Map;

    expect(properties['parent'], {
      'description': 'Parent category',
      'anyOf': [
        {r'$ref': '#/definitions/Category'},
        {'type': 'null'},
      ],
    });
    expect(jsonSchema['definitions'], isNotNull);
  });

  test('warns when lazy runtime checks cannot be exported', () {
    late final ObjectSchema categorySchema;
    categorySchema = Ack.object({
      'name': Ack.string(),
      'child': Ack.lazy<JsonMap, JsonMap>(
        'Category',
        () => categorySchema,
      ).refine((value) => true),
    });

    final model = categorySchema.toSchemaModel() as AckObjectSchemaModel;
    final child = model.properties!['child']!;

    expect(child.toJsonSchema(), {r'$ref': '#/definitions/Category'});
    expect(child.warnings, hasLength(1));
    expect(child.warnings.single.code, 'lazy_runtime_checks_not_export_safe');
    expect(child.warnings.single.context, {
      'constraintCount': 1,
      'refinementCount': 1,
    });
  });

  test('does not add definitions to non-lazy schemas', () {
    final schema = Ack.object({
      'name': Ack.string().minLength(2),
      'children': Ack.list(Ack.string()),
    });

    expect(schema.toJsonSchema(), {
      'type': 'object',
      'properties': {
        'name': {'type': 'string', 'minLength': 2},
        'children': {
          'type': 'array',
          'items': {'type': 'string'},
        },
      },
      'required': ['name', 'children'],
      'additionalProperties': false,
    });
    expect(schema.toJsonSchema(), isNot(contains('definitions')));
  });

  test('memoizes the builder result', () {
    var calls = 0;
    late final ObjectSchema categorySchema;
    final lazy = Ack.lazy<JsonMap, JsonMap>('Category', () {
      calls++;
      return categorySchema;
    });
    categorySchema = Ack.object({
      'name': Ack.string(),
      'children': Ack.list(lazy),
    });

    final json = <String, Object?>{
      'name': 'root',
      'children': [
        {'name': 'leaf', 'children': <Object?>[]},
      ],
    };

    final parsed = categorySchema.parse(json);
    expect(parsed, equals(json));
    expect(categorySchema.encode(parsed), equals(json));
    expect(calls, 1);
  });

  test('uses closure identity for equality', () {
    final target = Ack.object({'name': Ack.string()});
    final first = Ack.lazy<JsonMap, JsonMap>('Category', () => target);
    final second = Ack.lazy<JsonMap, JsonMap>('Category', () => target);

    expect(first, equals(first));
    expect(first, isNot(equals(second)));
  });

  test('encode runs lazy refinement once per nested node (no double '
      'validation)', () {
    var calls = 0;
    late final ObjectSchema categorySchema;
    final lazy = Ack.lazy<JsonMap, JsonMap>('Category', () => categorySchema)
        .refine((value) {
          calls++;
          return true;
        });
    categorySchema = Ack.object({
      'name': Ack.string(),
      'children': Ack.list(lazy),
    });

    final json = <String, Object?>{
      'name': 'root',
      'children': [
        {
          'name': 'a',
          'children': [
            {
              'name': 'b',
              'children': [
                {'name': 'c', 'children': <Object?>[]},
              ],
            },
          ],
        },
      ],
    };

    final parsed = categorySchema.parse(json);
    calls = 0;
    final encoded = categorySchema.encode(parsed);
    expect(encoded, equals(json));

    // Parent ObjectSchema/ListSchema validate-then-encode passes already drive
    // a fixed number of refinement runs per lazy edge. The double-validation
    // bug added an extra recursive validate inside LazySchema.encodeWithContext
    // on top of that, inflating this count. Locks in the fixed call profile.
    expect(calls, 15);
  });

  group('maxDepth', () {
    test('allows input at the cap and fails one level deeper', () {
      const maxDepth = 3;
      late final ObjectSchema categorySchema;
      final child = Ack.lazy<JsonMap, JsonMap>(
        'Category',
        () => categorySchema,
        maxDepth: maxDepth,
      ).nullable().optional();
      categorySchema = Ack.object({'name': Ack.string(), 'child': child});

      final atLimit = _nestedCategoryJson(maxDepth);
      final tooDeep = _nestedCategoryJson(maxDepth + 1);

      expect(categorySchema.safeParse(atLimit).isOk, isTrue);
      expect(categorySchema.safeParse(tooDeep).isFail, isTrue);
      expect(categorySchema.safeEncode(atLimit).isOk, isTrue);
      expect(categorySchema.safeEncode(tooDeep).isFail, isTrue);
    });

    test('defaults maxDepth to LazySchema.defaultMaxDepth', () {
      final target = Ack.object({'name': Ack.string()});
      final lazy = Ack.lazy<JsonMap, JsonMap>('Category', () => target);

      expect(lazy.maxDepth, LazySchema.defaultMaxDepth);
    });

    test('throws for maxDepth values below 1', () {
      final target = Ack.object({'name': Ack.string()});

      expect(
        () => Ack.lazy<JsonMap, JsonMap>('Category', () => target, maxDepth: 0),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () =>
            Ack.lazy<JsonMap, JsonMap>('Category', () => target, maxDepth: -1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('preserves maxDepth through fluent copies', () {
      final target = Ack.object({'name': Ack.string()});
      final lazy = Ack.lazy<JsonMap, JsonMap>(
        'Category',
        () => target,
        maxDepth: 2,
      );

      expect(lazy.maxDepth, 2);
      expect(lazy.nullable().optional().maxDepth, 2);
    });

    test('includes maxDepth in equality and hashCode', () {
      final target = Ack.object({'name': Ack.string()});
      AckSchema<JsonMap, JsonMap> builder() => target;

      final uncapped = Ack.lazy<JsonMap, JsonMap>('Category', builder);
      final capped = Ack.lazy<JsonMap, JsonMap>(
        'Category',
        builder,
        maxDepth: 2,
      );
      final matchingCap = Ack.lazy<JsonMap, JsonMap>(
        'Category',
        builder,
        maxDepth: 2,
      );

      expect(capped, matchingCap);
      expect(capped.hashCode, matchingCap.hashCode);
      expect(capped, isNot(uncapped));
    });

    test('terminates direct and indirect lazy aliases', () {
      late final LazySchema<String, String> direct;
      direct = Ack.lazy<String, String>('Direct', () => direct, maxDepth: 1);

      late final LazySchema<String, String> first;
      late final LazySchema<String, String> second;
      first = Ack.lazy<String, String>('First', () => second, maxDepth: 1);
      second = Ack.lazy<String, String>('Second', () => first, maxDepth: 1);

      for (final result in [direct.safeParse('x'), first.safeParse('x')]) {
        expect(result.isFail, isTrue);
        final error = result.getError();
        expect(error, isA<SchemaConstraintsError>());
        expect(error.message, contains('Maximum recursion depth'));
      }
    });

    test('terminates lazy aliases hidden behind wrappers', () {
      late final LazySchema<String, String> defaultWrapped;
      defaultWrapped = Ack.lazy<String, String>(
        'DefaultWrapped',
        () => defaultWrapped.withDefault('fallback'),
        maxDepth: 1,
      );

      late final LazySchema<String, String> codecWrapped;
      codecWrapped = Ack.lazy<String, String>(
        'CodecWrapped',
        () => codecWrapped.codec<String>(
          decode: (value) => value,
          encode: (value) => value,
        ),
        maxDepth: 1,
      );

      for (final schema in [defaultWrapped, codecWrapped]) {
        for (final result in [
          schema.safeParse('value'),
          schema.safeEncode('value'),
        ]) {
          expect(result.isFail, isTrue);
          final error = result.getError();
          expect(error, isA<SchemaConstraintsError>());
          expect(error.message, contains('Maximum recursion depth'));
        }
      }
    });

    test('terminates lazy aliases hidden behind fluent copies', () {
      late final LazySchema<String, String> optionalAlias;
      optionalAlias = Ack.lazy<String, String>(
        'OptionalAlias',
        () => optionalAlias.optional(),
        maxDepth: 1,
      );

      for (final result in [
        optionalAlias.safeParse('value'),
        optionalAlias.safeEncode('value'),
      ]) {
        expect(result.isFail, isTrue);
        final error = result.getError();
        expect(error, isA<SchemaConstraintsError>());
        expect(error.message, contains('Maximum recursion depth'));
      }
    });
  });
}

JsonMap _nestedCategoryJson(int childDepth) {
  JsonMap node = {'name': 'node-$childDepth'};
  for (var depth = childDepth - 1; depth >= 0; depth--) {
    node = {'name': 'node-$depth', 'child': node};
  }
  return node;
}

final class _TestJsonSchemaKeywordConstraint<T extends Object>
    extends Constraint<T>
    with Validator<T>, JsonSchemaSpec<T> {
  const _TestJsonSchemaKeywordConstraint(this.keywords)
    : super(
        constraintKey: 'test_schema_model_keywords',
        description: 'Adds test-only JSON Schema keywords.',
      );

  final Map<String, Object?> keywords;

  @override
  bool isValid(T value) => true;

  @override
  String buildMessage(T value) => 'ok';

  @override
  Map<String, Object?> toJsonSchema() => keywords;
}
