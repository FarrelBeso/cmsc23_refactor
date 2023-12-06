import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_refactor/backend/api_setting.dart';
import 'package:todo_refactor/backend/auth_api.dart';
import 'package:todo_refactor/backend/tasks_api.dart';
import 'package:todo_refactor/fakefirebase/fake_firebase_auth.dart';
import 'package:todo_refactor/model/task_model.dart';
import 'package:todo_refactor/model/user_model.dart';

void main() {
  final usermodel = UserModel(
      id: '1234XXX',
      firstName: 'Lorem',
      lastName: 'Ipsum',
      username: 'LoremIpsum',
      email: 'lorem@ipsum.com',
      birthday: DateTime(2000, 1, 2),
      location: 'Philippines');

  final taskmodel = TaskModel(
      id: '1234',
      taskName: 'Sample Task',
      status: 'Not Started',
      deadline: DateTime(2023, 12, 31, 23, 59),
      description: 'Sample Description',
      ownerId: '1234XXX',
      lastEditedDate: DateTime(2023, 12, 5, 17, 30),
      lastEditUserId: '1234XXX');

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

  // reset the auth and db every test
  setUp(() {
    currentAuth = FakeFirebaseAuth();
    currentFirebase = FakeFirebaseFirestore();
  });

  group('Tasks API Test', () {
    group('Happy Paths', () {
      test('Add task and get task info', () async {
        final taskapi = TasksAPI();
        final addres = await taskapi.addTask(taskmodel);
        expect(addres.success, true);
        final getres = await taskapi.getTaskInfo(taskmodel.id!);
        expect(getres.content.id, taskmodel.id);
      });

      test('Update the task', () async {
        final taskapi = TasksAPI();
        await taskapi.addTask(taskmodel);
        // create a copy
        final taskmodelcopy =
            taskmodel.copyWith(TaskModel(taskName: 'Changed Name'));
        final res = await taskapi.updateTask(taskmodelcopy);
        expect(res.success, true);
        final getres = await taskapi.getTaskInfo(taskmodel.id!);
        expect(getres.content.taskName, 'Changed Name');
      });

      test('Remove the task', () async {
        final taskapi = TasksAPI();
        await taskapi.addTask(taskmodel);
        final res = await taskapi.removeTask(taskmodel);
        expect(res.success, true);
        final getres = await taskapi.getTaskInfo(taskmodel.id!);
        expect(getres.success, false);
      });

      test('Get task ids from user', () async {
        final taskapi = TasksAPI();
        // fill the db
        await taskapi.addTask(task1);
        await taskapi.addTask(task2);
        await taskapi.addTask(task3);

        final res = await taskapi.getTaskIdsFromUser(usermodel.id!);
        expect(res.success, true);
        expect(res.content, [task1.id, task2.id, task3.id]);
      });
    });

    group('Sad Paths', () {
      test('Task not found', () async {
        final taskapi = TasksAPI();
        final res = await taskapi.getTaskInfo(usermodel.id!);
        expect(res.success, false);
      });
    });
  });
}

// cheat functions
Future<void> addUser(UserModel usermodel, String email, String password) async {
  currentAuth.addNewAccount(email, password, uid: usermodel.id);
  final docRef = currentFirebase
      .collection("users")
      .withConverter(
          fromFirestore: UserModel.fromFirestore,
          toFirestore: (UserModel model, options) => model.toFirestore())
      .doc(usermodel.id);
  await docRef.set(usermodel);
}
