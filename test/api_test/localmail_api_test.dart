import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_refactor/backend/api_setting.dart';
import 'package:todo_refactor/backend/auth_api.dart';
import 'package:todo_refactor/backend/localmail_api.dart';
import 'package:todo_refactor/fakefirebase/fake_firebase_auth.dart';
import 'package:todo_refactor/model/localmail_model.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/user_model.dart';

void main() {
  final usermodel = UserModel(
    id: '1234XXX',
    firstName: 'Lorem',
    lastName: 'Ipsum',
    username: 'LoremIpsum',
    email: 'lorem@ipsum.com',
    birthday: DateTime(2000, 1, 2),
    location: 'Philippines',
  );

  final mail1 = LocalMailModel(
      id: 'id1',
      type: 'sampletype',
      message: 'sample message',
      timestamp: DateTime.now());

  final mail2 = LocalMailModel(
      id: 'id2',
      type: 'sampletype',
      message: 'sample message',
      timestamp: DateTime.now());

  // reset the auth and db every test
  setUp(() {
    currentAuth = FakeFirebaseAuth();
    currentFirebase = FakeFirebaseFirestore();
  });

  group('User API Test', () {
    test('Add and check mail', () async {
      final localmailapi = LocalMailAPI();
      // autologin
      await setToLogin(usermodel, '12345678');
      ResponseModel res;
      // 1. add the two mails
      res = await localmailapi.addMailToUser(usermodel.id!, mail1);
      expect(res.success, true);
      res = await localmailapi.addMailToUser(usermodel.id!, mail2);
      expect(res.success, true);
      // 2. check the contents of the mail
      res = await localmailapi.getLocalMailFromUser();
      final reslist = res.content.map((mail) => mail.id).toList();
      expect(reslist, containsAll([mail1.id, mail2.id]));
    });

    test('No mail available', () async {
      final localmailapi = LocalMailAPI();
      // autologin
      await setToLogin(usermodel, '12345678');
      ResponseModel res;
      // 1. check the contents of the mail
      res = await localmailapi.getLocalMailFromUser();
      expect(res.content, hasLength(0));
    });
  });
}

// cheat functions
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
