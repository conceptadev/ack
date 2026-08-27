import 'package:ack/ack.dart';
import 'package:test/test.dart';

enum Status { active, archived }

void main() {
  group('BoundarySchema', () {
    final typedSchema = Ack.object({
      'createdAt': Ack.datetime(),
      'statuses': Ack.list(Ack.enumValues(Status.values)),
    });
    final wireSchema = Ack.preserveBoundary(typedSchema);

    test('validates codecs without retaining decoded values', () {
      final input = <String, Object?>{
        'createdAt': '2026-08-27T12:00:00Z',
        'statuses': ['active'],
      };

      final result = wireSchema.parse(input);

      expect(result, same(input));
      expect(result!['createdAt'], isA<String>());
      expect(result['statuses'], ['active']);
    });

    test('rejects invalid boundary values', () {
      final result = wireSchema.safeParse({
        'createdAt': 'not-a-date',
        'statuses': ['unknown'],
      });

      expect(result.isFail, isTrue);
    });

    test('canonicalizes compatible dynamic boundary containers', () {
      final input = <dynamic, dynamic>{
        'createdAt': '2026-08-27T12:00:00Z',
        'statuses': ['active'],
      };

      final result = wireSchema.parse(input);

      expect(result, input);
      expect(result, isA<Map<String, Object?>>());
    });

    test('encodes validated boundary values unchanged', () {
      final input = <String, Object?>{
        'createdAt': '2026-08-27T12:00:00Z',
        'statuses': ['archived'],
      };

      expect(wireSchema.encode(input), same(input));
    });

    test('exports the wrapped boundary contract', () {
      expect(wireSchema.toJsonSchema(), typedSchema.toJsonSchema());
    });
  });
}
