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
}
