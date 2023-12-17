import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_refactor/backend/api_setting.dart';
import 'package:todo_refactor/backend/auth_api.dart';
import 'package:todo_refactor/fakefirebase/fake_firebase_auth.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/user_model.dart';
import 'package:todo_refactor/provider/auth_provider.dart';

void main() {
  // long continuous test
  // providers to be used
  AuthProvider authProvider = AuthProvider();
  ResponseModel res;

  // mock data
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
  group('Auth Provider Test', () {
    test('Setting up', () {
      currentAuth = FakeFirebaseAuth();
      currentFirebase = FakeFirebaseFirestore();
      // adding test data
      addUser(friend1, '12345678');
    });
    test('Sign In Check', () async {
      await authProvider.signIn(usermodel, '12345678');
      res = await authProvider.fetchUser();
      expect(res.content.id, usermodel.id);
    });

    test('Sign Out Check', () async {
      await authProvider.signOut();
      res = await authProvider.fetchUser();
      expect(res.content, isNull);
    });

    test('Login Check', () async {
      await authProvider.login(usermodel.email!, '12345678');
      res = await authProvider.fetchUser();
      expect(res.content.id, usermodel.id);
    });

    test('Alter Login Check', () async {
      await authProvider.signOut();
      await authProvider.login(friend1.email!, '12345678');
      res = await authProvider.fetchUser();
      expect(res.content.id, friend1.id);
      await authProvider.signOut();
      res = await authProvider.fetchUser();
      expect(res.content, isNull);
    });
  });
}

Future<void> setToLogin(UserModel usermodel, String password) async {
  addUser(usermodel, password);
  await AuthAPI().login(usermodel.email!, password);
}

Future<void> addUser(UserModel usermodel, String password) async {
  currentAuth.addNewAccount(usermodel.email!, password, uid: usermodel.id);
  await AuthAPI().addToDatabase(usermodel);
}
