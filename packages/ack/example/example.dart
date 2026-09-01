// Validates a map against a schema, then exports the same schema as JSON
// Schema Draft-7. Run it with `dart run example/example.dart`.
import 'dart:convert';

import 'package:ack/ack.dart';

void main() {
  final userSchema = Ack.object({
    'name': Ack.string().minLength(2).maxLength(50),
    'email': Ack.string().email(),
    'age': Ack.integer().min(0).max(120).optional(),
  });

  final result = userSchema.safeParse({
    'name': 'Ada Lovelace',
    'email': 'ada@example.com',
    'age': 36,
  });

  if (result.isOk) {
    print('Valid user: ${result.getOrThrow()}');
  } else {
    print('Validation failed: ${result.getError()}');
  }

  // A missing required field fails, and the error names the field.
  final incomplete = userSchema.safeParse({'name': 'Ada'});
  print('Missing email: ${incomplete.getError()}');

  // The same schema exports as JSON Schema Draft-7.
  print(const JsonEncoder.withIndent('  ').convert(userSchema.toJsonSchema()));
}
