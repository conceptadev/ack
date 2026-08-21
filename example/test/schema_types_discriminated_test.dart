import 'package:ack_example/pet.dart' as explicit;
import 'package:ack_example/schema_types_discriminated.dart' as omitted;
import 'package:test/test.dart';

void main() {
  group('discriminated generated types with omitted branch discriminators', () {
    test('base parser returns the matching subtype', () {
      final cat = omitted.Pet.parse({'kind': 'cat', 'lives': 9});
      final dog = omitted.Pet.parse({'kind': 'dog', 'bark': true});

      expect(cat, isA<omitted.Cat>());
      expect(dog, isA<omitted.Dog>());
    });

    test('subtype parser rejects another valid union branch', () {
      final result = omitted.Cat.safeParse({'kind': 'dog', 'bark': true});

      expect(result.isFail, isTrue);
      expect(
        () => omitted.Cat.parse({'kind': 'dog', 'bark': true}),
        throwsA(anything),
      );
    });
  });

  group('discriminated generated types with explicit branch literals', () {
    test('base parser returns the matching subtype', () {
      final cat = explicit.Pet.parse({'type': 'cat', 'lives': 9});
      final dog = explicit.Pet.parse({'type': 'dog', 'breed': 'Poodle'});

      expect(cat, isA<explicit.Cat>());
      expect(dog, isA<explicit.Dog>());
    });

    test('subtype parser rejects another valid union branch', () {
      final result = explicit.Cat.safeParse({'type': 'dog', 'breed': 'Poodle'});

      expect(result.isFail, isTrue);
      expect(
        () => explicit.Cat.parse({'type': 'dog', 'breed': 'Poodle'}),
        throwsA(anything),
      );
    });
  });
}
