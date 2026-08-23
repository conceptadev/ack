import 'package:ack/ack.dart';
import 'package:test/test.dart';

void main() {
  test(
    'string convenience wrappers are one-way transforms',
    () {
      final wrappers =
          <String, CodecSchema<String, String> Function(StringSchema)>{
            'trim': (schema) => schema.trim(),
            'toLowerCase': (schema) => schema.toLowerCase(),
            'toUpperCase': (schema) => schema.toUpperCase(),
          };

      for (final entry in wrappers.entries) {
        final result = entry.value(Ack.string()).safeEncode('X');
        expect(result.isFail, isTrue, reason: entry.key);
        expect(
          (result.getError() as SchemaEncodeError).kind,
          SchemaEncodeFailureKind.oneWayTransform,
          reason: entry.key,
        );
      }
    },
  );
}
