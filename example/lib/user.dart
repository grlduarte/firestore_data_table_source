import 'package:faker/faker.dart';

class User {
  final String name;
  final String lastName;

  const User({
    required this.name,
    required this.lastName,
  });

  factory User.fake() {
    final faker = Faker();
    final person = faker.person;

    return User(
      name: person.firstName(),
      lastName: person.lastName(),
    );
  }

  factory User.fromJson(Map<String, Object?> json) => User(
        name: json['name'] as String,
        lastName: json['lastName'] as String,
      );

  Map<String, Object?> toJson() => <String, dynamic>{
        'name': name,
        'lastName': lastName,
      };
}
