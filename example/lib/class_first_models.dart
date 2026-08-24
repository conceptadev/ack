import 'package:ack/ack.dart';
import 'package:ack_annotations/ack_annotations.dart';

part 'class_first_models.ack.dart';
part 'class_first_models.g.dart';

@AckModel(caseStyle: AckCaseStyle.snake)
final class Account {
  const Account({
    required this.displayName,
    this.website,
    this.role = 'member',
  });

  @MinLength(2)
  final String displayName;
  final Uri? website;
  final String role;

  factory Account.fromJson(Map<String, dynamic> json) =>
      accountSchema.parse(json)!;
}

@AckModel(discriminatorKey: 'type')
sealed class Pet {
  const Pet({required this.id});

  final String id;
}

@AckModel(discriminatorValue: 'cat')
final class Cat extends Pet {
  const Cat({required super.id, required this.lives});

  @Min(1)
  @Max(9)
  final int lives;
}

final class Dog extends Pet {
  const Dog({required super.id, required this.breed});

  final String breed;
}
