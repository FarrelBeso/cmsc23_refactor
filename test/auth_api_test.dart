import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_refactor/backend/api_setting.dart';
import 'package:todo_refactor/backend/auth_api.dart';
import 'package:todo_refactor/fakefirebase/fake_firebase_auth.dart';
import 'package:todo_refactor/model/user_model.dart';

void main() {
  final usermodel = UserModel(
      firstName: 'Lorem',
      lastName: 'Ipsum',
      username: 'LoremIpsum',
      email: 'lorem@ipsum.com',
      birthday: DateTime(2000, 1, 2),
      location: 'Philippines');

  // reset the auth and db every test
  setUp(() {
    currentAuth = FakeFirebaseAuth();
    currentFirebase = FakeFirebaseFirestore();
  });

  group('Happy Paths', () {
    test('Sign In and Add to Database', () async {
      final authapi = AuthAPI();
      final res = await authapi.signIn(usermodel, '12345678');
      expect(res.success, true);
      expect(res.message, 'Successfully signed in.');
      expect(authapi.currentUser, isNotNull);
    });

    test('Log In', () async {
      final authapi = AuthAPI();
      // inject here
      await addUser(usermodel, 'lorem@ipsum.com', '12345678');
      final res = await authapi.login('lorem@ipsum.com', '12345678');
      expect(res.success, true);
      expect(res.message, 'Successfully logged in.');
      expect(authapi.currentUser, isNotNull);
    });

    test('Sign Out', () async {
      final authapi = AuthAPI();
      await authapi.signIn(usermodel, '12345678');
      final res = await authapi.signOut();
      expect(res.success, true);
      expect(res.message, 'Successfully signed out.');
      expect(authapi.currentUser, isNull);
    });

    test('Get from Database', () async {
      final authapi = AuthAPI();
      await authapi.signIn(usermodel, '12345678');
      expect(authapi.currentUser, isNotNull);
      final res = await authapi.getCurrentUser();
      expect(res.success, true);
      expect(res.content, isNotNull);
    });
  });
}

// cheat functions
Future<void> addUser(UserModel usermodel, String email, String password) async {
  final fakeuser = currentAuth.addNewAccount(email, password);
  usermodel.id = fakeuser.uid;
  final docRef = currentFirebase
      .collection("users")
      .withConverter(
          fromFirestore: UserModel.fromFirestore,
          toFirestore: (UserModel model, options) => model.toFirestore())
      .doc(usermodel.id);
  await docRef.set(usermodel);
}
