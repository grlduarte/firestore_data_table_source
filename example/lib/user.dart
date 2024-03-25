import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String name;
  final String lastName;

  const User({
    required this.name,
    required this.lastName,
  });

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
