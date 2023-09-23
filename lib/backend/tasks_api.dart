import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/task_model.dart';

class TasksAPI {
  final db = FirebaseFirestore.instance;

  // make sure the data is complete before sending here
  Future<ResponseModel> addTask(TaskModel taskmodel) async {
    try {
      final docRef = db
          .collection("tasks")
          .withConverter(
              fromFirestore: TaskModel.fromFirestore,
              toFirestore: (TaskModel model, options) => model.toFirestore())
          .doc(taskmodel.id);
      await docRef.set(taskmodel);
      return ResponseModel(success: true, message: 'Task added successfully.');
    } catch (e) {
      return ResponseModel(success: false, message: 'Failed to add task.');
    }
  }

  // make sure other fields are complete here such as the time stamp
  // this is similar to add task
  Future<ResponseModel> updateTask(TaskModel taskmodel) async {
    try {
      final docRef = db
          .collection("tasks")
          .withConverter(
              fromFirestore: TaskModel.fromFirestore,
              toFirestore: (TaskModel model, options) => model.toFirestore())
          .doc(taskmodel.id);
      await docRef.set(taskmodel);
      return ResponseModel(
          success: true, message: 'Task updated successfully.');
    } catch (e) {
      return ResponseModel(success: false, message: 'Failed to update task.');
    }
  }

  // remove task, only the task and not the reference
  Future<ResponseModel> removeTask(TaskModel taskmodel) async {
    try {
      final docRef = db.collection("tasks").doc(taskmodel.id);
      await docRef.delete();
      return ResponseModel(
          success: true, message: 'Task removed successfully.');
    } catch (e) {
      return ResponseModel(success: false, message: 'Failed to remove task.');
    }
  }

  // fetch task ids of the given user
  Future<ResponseModel> getTaskIdsFromUser(String id) async {
    try {
      List<String> taskIds = [];
      await db
          .collection("tasks")
          .where("ownerId", isEqualTo: id)
          .get()
          .then((querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          taskIds.add(docSnapshot.id);
        }
      });
      return ResponseModel(
          success: true,
          message: 'Task ids retrieved successfully',
          content: taskIds);
    } catch (e) {
      return ResponseModel(
          success: false, message: 'Failed to retrieve task ids.');
    }
  }

  // fetch info about a particular task id
  Future<ResponseModel> getTaskInfo(String id) async {
    try {
      final docRef = db.collection("tasks").doc(id).withConverter(
          fromFirestore: TaskModel.fromFirestore,
          toFirestore: (TaskModel model, _) => model.toFirestore());
      final docSnap = await docRef.get();
      TaskModel taskmodel = docSnap.data()!;
      return ResponseModel(
          success: true,
          message: 'Task model retrieved successfully',
          content: taskmodel);
    } catch (e) {
      return ResponseModel(
          success: false, message: 'Failed to retrieve task model');
    }
  }
}
