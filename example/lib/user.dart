import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String name;
  final String lastName;
  final DateTime birthday;

  const User({
    required this.name,
    required this.lastName,
    required this.birthday,
  });

  factory User.fromJson(Map<String, Object?> json) => User(
        name: json['name'] as String,
        lastName: json['lastName'] as String,
        birthday: (json['birthday'] as Timestamp).toDate(),
      );

  Map<String, Object?> toJson() => <String, dynamic>{
        'name': name,
        'lastName': lastName,
        'birthday': Timestamp.fromDate(birthday),
      };
}

final usersRef =
    FirebaseFirestore.instance.collection('users').withConverter<User>(
          fromFirestore: (snapshot, _) => User.fromJson(snapshot.data()!),
          toFirestore: (user, _) => user.toJson(),
        );
