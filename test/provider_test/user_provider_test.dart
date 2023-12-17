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
import 'package:todo_refactor/provider/task_provider.dart';
import 'package:todo_refactor/provider/user_provider.dart';
import 'package:todo_refactor/utilities/task_utils.dart';
import 'package:todo_refactor/utilities/user_utils.dart';

void main() {
  // long continuous test
  // providers to be used
  AuthProvider authProvider = AuthProvider();
  TaskProvider taskProvider = TaskProvider();
  UserProvider userProvider = UserProvider();
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

  final friend2 = UserModel(
      id: '9012XXX',
      firstName: 'Friend',
      lastName: 'Smith',
      username: 'friendtwo',
      email: 'friend@two.com',
      birthday: DateTime(2000, 1, 2),
      location: 'Philippines');

  final friend3 = UserModel(
      id: '3456XXX',
      firstName: 'Friend',
      lastName: 'Smith',
      username: 'friendthree',
      email: 'friend@three.com',
      birthday: DateTime(2000, 1, 2),
      location: 'Philippines');

  group('User Provider Test', () {
    test('Setting up', () async {
      currentAuth = FakeFirebaseAuth();
      currentFirebase = FakeFirebaseFirestore();
      // adding test data
      await addUser(usermodel, '12345678');
      await addUser(friend1, '12345678');
      await addUser(friend2, '12345678');
      await addUser(friend3, '12345678');
      // login
      await authProvider.login(usermodel.email!, '12345678');
    });

    test('No query', () async {
      await userProvider.updateUserList('');
      final ids = userProvider.userlist!.map((user) => user.id).toList();
      expect(ids, hasLength(3));
      expect(ids, containsAll([friend1.id, friend2.id, friend3.id]));
    });

    test('Query by username', () async {
      await userProvider.updateUserList('friendone');
      final ids = userProvider.userlist!.map((user) => user.id).toList();
      expect(ids, hasLength(1));
      expect(ids, containsAll([friend1.id]));
    });

    test('Query by lastname', () async {
      await userProvider.updateUserList('Smith');
      final ids = userProvider.userlist!.map((user) => user.id).toList();
      expect(ids, hasLength(2));
      expect(ids, containsAll([friend2.id, friend3.id]));
    });

    test('Query by firstname', () async {
      await userProvider.updateUserList('Granny');
      final ids = userProvider.userlist!.map((user) => user.id).toList();
      expect(ids, hasLength(0));
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
