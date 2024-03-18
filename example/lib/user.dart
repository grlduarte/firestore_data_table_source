import 'package:cloud_firestore/cloud_firestore.dart';
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
    final birthday = faker.date.dateTime(minYear: 1950, maxYear: 2020);

    return User(
      name: person.firstName(),
      lastName: person.lastName(),
      birthday: birthday,
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

final usersRef =
    FirebaseFirestore.instance.collection('users').withConverter<User>(
          fromFirestore: (snapshot, _) => User.fromJson(snapshot.data()!),
          toFirestore: (user, _) => user.toJson(),
        );
