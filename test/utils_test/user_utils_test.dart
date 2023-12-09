import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_refactor/backend/api_setting.dart';
import 'package:todo_refactor/backend/auth_api.dart';
import 'package:todo_refactor/backend/tasks_api.dart';
import 'package:todo_refactor/backend/user_api.dart';
import 'package:todo_refactor/fakefirebase/fake_firebase_auth.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/task_model.dart';
import 'package:todo_refactor/model/user_model.dart';
import 'package:todo_refactor/utilities/task_utils.dart';
import 'package:todo_refactor/utilities/user_utils.dart';

void main() {
  final usermodel = UserModel(
      id: '1234XXX',
      firstName: 'Lorem',
      lastName: 'Ipsum',
      username: 'LoremIpsum',
      email: 'lorem@ipsum.com',
      birthday: DateTime(2000, 1, 2),
      location: 'Philippines');

  final friend1 = UserModel(
      id: '5678XXX',
      firstName: 'Friend',
      lastName: 'One',
      username: 'friendone',
      email: 'friend@one.com',
      birthday: DateTime(2000, 1, 2),
      location: 'Philippines');

  final friend2 = UserModel(
      id: '9012XXX',
      firstName: 'Friend',
      lastName: 'Two',
      username: 'friendtwo',
      email: 'friend@two.com',
      birthday: DateTime(2000, 1, 2),
      location: 'Philippines');

  final friend3 = UserModel(
      id: '3456XXX',
      firstName: 'Friend',
      lastName: 'Three',
      username: 'friendthree',
      email: 'friend@three.com',
      birthday: DateTime(2000, 1, 2),
      location: 'Philippines');

  // reset the auth and db every test
  setUp(() {
    currentAuth = FakeFirebaseAuth();
    currentFirebase = FakeFirebaseFirestore();
  });

  group('Task Utils Test', () {
    group('Happy Paths', () {
      test('Get user', () async {
        final userutils = UserUtils();
      });
    });

    group('Sad Paths', () {});
  });
}

Future<void> setToLogin(UserModel usermodel, String password) async {
  addUser(usermodel, password);
  await AuthAPI().login(usermodel.email!, password);
}

Future<void> addUser(UserModel usermodel, String password) async {
  currentAuth.addNewAccount(usermodel.email!, password, uid: usermodel.id);
  final docRef = currentFirebase
      .collection("users")
      .withConverter(
          fromFirestore: UserModel.fromFirestore,
          toFirestore: (UserModel model, options) => model.toFirestore())
      .doc(usermodel.id);
  await docRef.set(usermodel);
}
