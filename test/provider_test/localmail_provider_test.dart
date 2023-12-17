import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_refactor/backend/api_setting.dart';
import 'package:todo_refactor/backend/auth_api.dart';
import 'package:todo_refactor/backend/tasks_api.dart';
import 'package:todo_refactor/fakefirebase/fake_firebase_auth.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/task_model.dart';
import 'package:todo_refactor/model/user_model.dart';
import 'package:todo_refactor/provider/auth_provider.dart';
import 'package:todo_refactor/provider/localmail_provider.dart';
import 'package:todo_refactor/provider/task_provider.dart';
import 'package:todo_refactor/provider/user_provider.dart';
import 'package:todo_refactor/utilities/localmail_utils.dart';
import 'package:todo_refactor/utilities/task_utils.dart';
import 'package:todo_refactor/utilities/user_utils.dart';

void main() {
  // long continuous test
  // providers to be used
  AuthProvider authProvider = AuthProvider();
  TaskProvider taskProvider = TaskProvider();
  UserProvider userProvider = UserProvider();
  LocalMailProvider localMailProvider = LocalMailProvider();
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

  final task = TaskModel(
      id: '12XXX',
      taskName: 'Task 1',
      status: 'Not Started',
      deadline: DateTime(2023, 12, 31, 23, 59),
      description: 'Sample Description',
      ownerId: '1234XXX',
      lastEditedDate: DateTime(2023, 12, 5, 17, 30),
      lastEditUserId: '1234XXX');

  // generate fake mails
  final mail1 = LocalMailUtils().editMail('1234XXX', task, task);
  final mail2 = LocalMailUtils().editMail('5678XXX', task, task);
  final mail3 = LocalMailUtils().editMail('9012XXX', task, task);

  group('LocalMail Provider Test', () {
    test('Setting up', () async {
      currentAuth = FakeFirebaseAuth();
      currentFirebase = FakeFirebaseFirestore();
      // adding test data
      await addUser(usermodel, '12345678');
      // attach mails to user
      await LocalMailUtils().addMailToUsers([usermodel.id!], mail1);
      await LocalMailUtils().addMailToUsers([usermodel.id!], mail2);
      await LocalMailUtils().addMailToUsers([usermodel.id!], mail3);

      // login
      await authProvider.login(usermodel.email!, '12345678');
    });

    test('Retrieve mails', () async {
      // we should get mails
      await localMailProvider.updateFeed();
      final ids = localMailProvider.mailFeed!.map((mail) => mail.id).toList();
      expect(ids, hasLength(3));
      expect(ids, containsAll([mail1.id, mail2.id, mail3.id]));
    });
  });
}

Future<void> assertFriendship(UserModel currentUser, String currentUserPass,
    UserModel otherUser, String otherUserPass) async {
  // assuming users already exist
  await AuthAPI().login(currentUser.email!, currentUserPass);
  await UserUtils().addFriend(otherUser.id!);
  await AuthAPI().signOut();
  await AuthAPI().login(otherUser.email!, otherUserPass);
  await UserUtils().acceptRequest(currentUser.id!);
  await AuthAPI().signOut();
}

Future<void> bindTasksToUser(
    UserModel usermodel, String password, List<TaskModel> tasklist) async {
  // assuming user already exists
  await AuthAPI().login(usermodel.email!, password);
  for (final task in tasklist) {
    await TasksAPI().addTask(task);
  }
  await AuthAPI().signOut();
}

Future<void> setToLogin(UserModel usermodel, String password) async {
  addUser(usermodel, password);
  await AuthAPI().login(usermodel.email!, password);
}

Future<void> addUser(UserModel usermodel, String password) async {
  currentAuth.addNewAccount(usermodel.email!, password, uid: usermodel.id);
  await AuthAPI().addToDatabase(usermodel);
}
