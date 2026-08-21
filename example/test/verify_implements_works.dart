import 'package:ack_example/schema_types_simple.dart';
import 'package:test/test.dart';

void main() {
  group('Generated immutable model', () {
    test('exposes typed fields and an explicit JSON boundary', () {
      final user = User.parse({'name': 'John', 'age': 30, 'active': true});

      expect(user.name, 'John');
      expect(user.age, 30);
      expect(user.active, true);
      expect(user.toJson(), {'name': 'John', 'age': 30, 'active': true});
    });

    test('safeParse returns SchemaResult<User>', () {
      final result = User.safeParse({
        'name': 'John',
        'age': 30,
        'active': true,
      });

      expect(result.isOk, true);
      final user = result.getOrNull();
      expect(user, isA<User>());
      expect(user?.name, 'John');
      expect(user?.age, 30);
    });

    test('safeParse failure preserves the typed result contract', () {
      final result = User.safeParse({'name': 'John'});

      expect(result.isFail, true);
      expect(result.getOrNull(), isNull);
    });
  });
}
