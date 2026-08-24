import 'package:ack_example/class_first_models.dart';
import 'package:test/test.dart';

void main() {
  test('class-first object schemas validate and map JSON keys', () {
    final account = Account.fromJson({'display_name': 'Ada'});

    expect(account.role, 'member');
    expect(account.toJson(), {'display_name': 'Ada', 'role': 'member'});
  });

  test('class-first sealed models dispatch through a discriminator', () {
    final pet = petSchema.parse({'type': 'cat', 'id': 'c1', 'lives': 9})!;

    expect(pet, isA<Cat>());
    expect(pet.toJson(), {'type': 'cat', 'id': 'c1', 'lives': 9});
  });
}
