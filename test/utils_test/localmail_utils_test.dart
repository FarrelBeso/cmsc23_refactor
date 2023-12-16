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
import 'package:todo_refactor/utilities/localmail_utils.dart';
import 'package:todo_refactor/utilities/task_utils.dart';

void main() {
  final usermodel1 = UserModel(
      id: '1234XXX',
      firstName: 'Lorem',
      lastName: 'Ipsum',
      username: 'LoremIpsum',
      email: 'lorem@ipsum.com',
      birthday: DateTime(2000, 1, 2),
      location: 'Philippines');

  final usermodel2 = UserModel(
      id: '5678XXX',
      firstName: 'Friend',
      lastName: 'One',
      username: 'friendone',
      email: 'friend@one.com',
      birthday: DateTime(2000, 1, 2),
      location: 'Philippines');

  final task1 = TaskModel(
      id: '12XXX',
      taskName: 'Task 1',
      status: 'Not Started',
      deadline: DateTime(2023, 12, 31, 23, 59),
      description: 'Sample Description',
      ownerId: '1234XXX',
      lastEditedDate: DateTime(2023, 12, 5, 17, 30),
      lastEditUserId: '1234XXX');

  final task2 = TaskModel(
      id: '34XXX',
      taskName: 'Task 2',
      status: 'Not Started',
      deadline: DateTime(2023, 12, 31, 23, 59),
      description: 'Sample Description',
      ownerId: '1234XXX',
      lastEditedDate: DateTime(2023, 12, 5, 17, 30),
      lastEditUserId: '1234XXX');

  // reset the auth and db every test
  setUp(() {
    currentAuth = FakeFirebaseAuth();
    currentFirebase = FakeFirebaseFirestore();
  });

  group('Task Utils Test', () {
    group('Happy Paths', () {
      test('Add mail to users', () async {
        final localmailutils = LocalMailUtils();
        ResponseModel res;
        List reslist;
        // add users
        await addUser(usermodel1, '12345678');
        await addUser(usermodel2, '12345678');
        // generate fake mails
        final editmail = localmailutils.editMail('edit', task1, task2);
        final deletemail = localmailutils.deleteMail('delete', task1, task2);
        final requestpendingmail =
            localmailutils.requestPendingMail('request', usermodel1);
        final requestconfirmmail =
            localmailutils.requestConfirmMail('confirm', usermodel2);
        // disseminate the mails
        await localmailutils
            .addMailToUsers([usermodel1.id!, usermodel2.id!], editmail);
        await localmailutils
            .addMailToUsers([usermodel1.id!, usermodel2.id!], deletemail);
        await localmailutils.addMailToUsers(
            [usermodel1.id!, usermodel2.id!], requestpendingmail);
        await localmailutils.addMailToUsers(
            [usermodel1.id!, usermodel2.id!], requestconfirmmail);
        // check on each accs
        await AuthAPI().login(usermodel1.email!, '12345678');
        res = await localmailutils.getLocalMailFromUser();
        reslist = res.content.map((mail) => mail.id).toList();
        expect(reslist, hasLength(4));
        expect(
            reslist,
            containsAll([
              editmail.id,
              deletemail.id,
              requestpendingmail.id,
              requestconfirmmail.id
            ]));
        await AuthAPI().signOut();
        // the other acc
        await AuthAPI().login(usermodel2.email!, '12345678');
        res = await localmailutils.getLocalMailFromUser();
        reslist = res.content.map((mail) => mail.id).toList();
        expect(reslist, hasLength(4));
        expect(
            reslist,
            containsAll([
              editmail.id,
              deletemail.id,
              requestpendingmail.id,
              requestconfirmmail.id
            ]));
        await AuthAPI().signOut();
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
