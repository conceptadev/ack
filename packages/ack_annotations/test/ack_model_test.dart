import 'package:ack_annotations/ack_annotations.dart';
import 'package:test/test.dart';

Object _customSchema() => Object();

void main() {
  test('AckModel options are const and default to class-first conventions', () {
    const defaults = AckModel();
    expect(defaults.schemaName, isNull);
    expect(defaults.caseStyle, AckCaseStyle.none);
    expect(defaults.discriminatorKey, isNull);
    expect(defaults.discriminatorValue, isNull);
    expect(defaults.additionalProperties, isFalse);

    const configured = AckModel(
      schemaName: 'wireUser',
      caseStyle: AckCaseStyle.snake,
      discriminatorKey: 'type',
      discriminatorValue: 'user',
      additionalProperties: true,
    );
    expect(configured.schemaName, 'wireUser');
    expect(configured.caseStyle, AckCaseStyle.snake);
    expect(configured.discriminatorKey, 'type');
    expect(configured.discriminatorValue, 'user');
    expect(configured.additionalProperties, isTrue);
    expect(AckCaseStyle.values, const [
      AckCaseStyle.none,
      AckCaseStyle.snake,
      AckCaseStyle.kebab,
      AckCaseStyle.pascal,
      AckCaseStyle.screamingSnake,
    ]);
  });

  test('AckField accepts a const top-level schema-function tear-off', () {
    const field = AckField(schema: _customSchema);
    expect(field.schema, same(_customSchema));
  });

  test('constraint sugar annotations are const data', () {
    const annotations = <Object>[
      Min(1),
      Max(9),
      MultipleOf(2),
      Positive(),
      Negative(),
      MinLength(1),
      MaxLength(100),
      Pattern(r'^[a-z]+$'),
      Email(),
      NotEmpty(),
      MinItems(1),
      MaxItems(10),
      UniqueItems(),
    ];

    expect((annotations[0] as Min).value, 1);
    expect((annotations[1] as Max).value, 9);
    expect((annotations[2] as MultipleOf).value, 2);
    expect((annotations[5] as MinLength).length, 1);
    expect((annotations[6] as MaxLength).length, 100);
    expect((annotations[7] as Pattern).pattern, r'^[a-z]+$');
    expect((annotations[10] as MinItems).count, 1);
    expect((annotations[11] as MaxItems).count, 10);
  });

  test('JsonKey is re-exported without importing json_annotation', () {
    const key = JsonKey(name: 'wire_name');
    expect(key.name, 'wire_name');
  });
}
