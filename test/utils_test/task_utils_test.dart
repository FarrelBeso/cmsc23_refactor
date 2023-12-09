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

  final task3 = TaskModel(
      id: '56XXX',
      taskName: 'Task 3',
      status: 'Not Started',
      deadline: DateTime(2023, 12, 31, 23, 59),
      description: 'Sample Description',
      ownerId: '1234XXX',
      lastEditedDate: DateTime(2023, 12, 5, 17, 30),
      lastEditUserId: '1234XXX');

  final friendtask1 = TaskModel(
      id: '78XXX',
      taskName: 'Task 4',
      status: 'Not Started',
      deadline: DateTime(2023, 12, 31, 23, 59),
      description: 'Sample Description',
      ownerId: '5678XXX',
      lastEditedDate: DateTime(2023, 12, 5, 17, 30),
      lastEditUserId: '5678XXX');

  final friendtask2 = TaskModel(
      id: '90XXX',
      taskName: 'Task 5',
      status: 'Not Started',
      deadline: DateTime(2023, 12, 31, 23, 59),
      description: 'Sample Description',
      ownerId: '9012XXX',
      lastEditedDate: DateTime(2023, 12, 5, 17, 30),
      lastEditUserId: '9012XXX');

  // reset the auth and db every test
  setUp(() {
    currentAuth = FakeFirebaseAuth();
    currentFirebase = FakeFirebaseFirestore();
  });

  group('Task Utils Test', () {
    group('Happy Paths', () {
      test('Add task, retrieve task info, then remove task', () async {
        final taskutils = TaskUtils();
        ResponseModel res;
        // autologin
        await setToLogin(usermodel, '12345678');
        // 1. add task
        res = await taskutils.addTask(task1);
        expect(res.success, true);
        // db checks
        res = await TasksAPI().getTaskIdsFromUser(usermodel.id!);
        expect(res.content, contains(task1.id));
        res = await UserAPI().getUser(usermodel.id!);
        expect(res.content.taskOwnIds, contains(task1.id));
        // 2. get task from id
        res = await taskutils.getTaskFromId(task1.id!);
        expect(res.content.id, task1.id);
        // 3. remove task
        res = await taskutils.removeTask(task1);
        expect(res.success, true);
        // db checks
        res = await TasksAPI().getTaskIdsFromUser(usermodel.id!);
        expect(res.content, isEmpty);
        res = await UserAPI().getUser(usermodel.id!);
        expect(res.content.taskOwnIds, isEmpty);
      });

      test('Get task list from a user', () async {
        final taskutils = TaskUtils();
        ResponseModel res;
        // autologin
        await setToLogin(usermodel, '12345678');
        // add tasks
        await taskutils.addTask(task1);
        await taskutils.addTask(task2);
        await taskutils.addTask(task3);
        // get task list
        res = await taskutils.getTaskList(usermodel.id!);
        final reslist = res.content.map((task) => task.id).toList();
        expect(reslist, containsAll([task1.id, task2.id, task3.id]));
      });

      test('Get task list from current user (with friends\'s)', () async {
        final taskutils = TaskUtils();
        ResponseModel res;
        // add tasks to friends and friend request to main user
        await setToLogin(friend1, '12345678');
        await taskutils.addTask(friendtask1);
        await UserAPI().addFriend(friend1.id!, usermodel.id!);
        await AuthAPI().signOut();
        await setToLogin(friend2, '12345678');
        await taskutils.addTask(friendtask2);
        await UserAPI().addFriend(friend1.id!, usermodel.id!);
        await AuthAPI().signOut();
        // autologin
        await setToLogin(usermodel, '12345678');
        await taskutils.addTask(task1);
        // accept requests
        await UserAPI().acceptRequest(friend1.id!, usermodel.id!);
        await UserAPI().acceptRequest(friend2.id!, usermodel.id!);
        // the three tasks should be shown
        res = await taskutils.getTaskListFromUser();
        final reslist = res.content.map((task) => task.id).toList();
        expect(
            reslist, containsAll([friendtask1.id, friendtask2.id, task1.id]));
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
