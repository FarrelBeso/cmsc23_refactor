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
import 'package:todo_refactor/utilities/task_utils.dart';

void main() {
  // long continuous test
  // providers to be used
  AuthProvider authProvider = AuthProvider();
  TaskProvider taskProvider = TaskProvider();
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

  final task4 = TaskModel(
      id: '78XXX',
      taskName: 'Task 4',
      status: 'Not Started',
      deadline: DateTime(2023, 12, 31, 23, 59),
      description: 'Sample Description',
      ownerId: '1234XXX',
      lastEditedDate: DateTime(2023, 12, 5, 17, 30),
      lastEditUserId: '1234XXX');

  group('Task Provider Test', () {
    test('Setting up', () async {
      currentAuth = FakeFirebaseAuth();
      currentFirebase = FakeFirebaseFirestore();
      // adding test data
      addUser(usermodel, '12345678');
      // bind tasks
      bindTasksToUser(usermodel, '12345678', [task1, task2, task3]);
      // login
      await authProvider.login(usermodel.email!, '12345678');
    });

    test('Update Task List', () async {
      await taskProvider.updateTaskList();
      // check
      final ids = taskProvider.tasklist!.map((task) => task.id);
      expect(ids, hasLength(3));
      expect(ids, containsAll([task1.id, task2.id, task3.id]));
    });

    test('Add Task', () async {
      await taskProvider.addTask(task4);
      // check
      final ids = taskProvider.tasklist!.map((task) => task.id);
      expect(ids, hasLength(4));
      expect(ids, containsAll([task1.id, task2.id, task3.id, task4.id]));
    });

    test('Update Task', () async {
      // edit the 1st task
      task1.status = 'Done';
      await taskProvider.updateTask(task1);
      // check
      final ids = taskProvider.tasklist!.map((task) => task.id);
      expect(ids, hasLength(4));
      expect(ids, containsAll([task1.id, task2.id, task3.id, task4.id]));
      res = await TaskUtils().getTaskFromId(task1.id!);
      expect(res.content.status, 'Done');
    });

    test('Remove Task', () async {
      await taskProvider.removeTask(task1);
      // check
      final ids = taskProvider.tasklist!.map((task) => task.id);
      expect(ids, hasLength(3));
      expect(ids, containsAll([task2.id, task3.id, task4.id]));
    });
  });
}

Future<void> bindTasksToUser(
    UserModel usermodel, String password, List<TaskModel> tasklist) async {
  // assuming user already exists
  await AuthAPI().login(usermodel.email!, password);
  for (final task in tasklist) {
    await TasksAPI().addTask(task);
  }
}

Future<void> setToLogin(UserModel usermodel, String password) async {
  addUser(usermodel, password);
  await AuthAPI().login(usermodel.email!, password);
}

Future<void> addUser(UserModel usermodel, String password) async {
  currentAuth.addNewAccount(usermodel.email!, password, uid: usermodel.id);
  await AuthAPI().addToDatabase(usermodel);
}
