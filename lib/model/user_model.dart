import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  // required objects are required from forms
  String? id;
  String? firstName;
  String? lastName;
  String? username;
  String? email;
  DateTime? birthday;
  String? location;
  // optional
  String? biography;
  List<String>? friendIds;
  List<String>? taskOwnIds;
  UserModel(
      {
      // required objects are required from forms
      this.id,
      this.firstName,
      this.lastName,
      this.username,
      this.email,
      this.birthday,
      this.location,
      // optional bits
      this.biography,
      this.friendIds,
      this.taskOwnIds});

  // copying some parts
  UserModel copyWith(UserModel other) {
    return UserModel(
        id: other.id ?? id,
        firstName: other.firstName ?? firstName,
        lastName: other.lastName ?? lastName,
        username: other.username ?? username,
        email: other.email ?? email,
        birthday: other.birthday ?? birthday,
        location: other.location ?? location,
        // optional
        biography: other.biography ?? biography,
        friendIds: other.friendIds ?? friendIds,
        taskOwnIds: other.taskOwnIds ?? taskOwnIds);
  }

  // convert to firestore
  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) "id": id,
      if (firstName != null) "firstName": firstName,
      if (lastName != null) "lastName": lastName,
      if (username != null) "username": username,
      if (email != null) "email": email,
      if (birthday != null) "birthday": birthday,
      if (location != null) "location": location,
      // optional
      if (biography != null) "biography": biography,
      if (friendIds != null) "friendIds": friendIds,
      if (taskOwnIds != null) "taskOwnIds": taskOwnIds,
    };
  }

  // convert from firestore
  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return UserModel(
      id: data?['id'],
      firstName: data?['firstName'],
      lastName: data?['lastName'],
      username: data?['username'],
      email: data?['email'],
      birthday: data?['birthday'],
      location: data?['location'],
      // optional
      biography: data?['biography'],
      friendIds:
          data?['friendIds'] is Iterable ? List.from(data?['friendIds']) : null,
      taskOwnIds: data?['taskOwnIds'] is Iterable
          ? List.from(data?['taskOwnIds'])
          : null,
    );
  }
}
