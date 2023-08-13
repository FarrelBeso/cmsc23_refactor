import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_refactor/model/task_model.dart';

class TasksAPI {
  final db = FirebaseFirestore.instance;

  // make sure the data is complete before sending here
  Future<void> addTask(TaskModel taskmodel) async {
    final docRef = db
        .collection("tasks")
        .withConverter(
            fromFirestore: TaskModel.fromFirestore,
            toFirestore: (TaskModel model, options) => model.toFirestore())
        .doc(taskmodel.id);
    await docRef.set(taskmodel);
  }

  // make sure other fields are complete here such as the time stamp
  // this is similar to add task
  Future<void> updateTask(TaskModel taskmodel) async {
    final docRef = db
        .collection("tasks")
        .withConverter(
            fromFirestore: TaskModel.fromFirestore,
            toFirestore: (TaskModel model, options) => model.toFirestore())
        .doc(taskmodel.id);
    await docRef.set(taskmodel);
  }

  // remove task, only the task and not the reference
  Future<void> removeTask(TaskModel taskmodel) async {
    final docRef = db.collection("tasks").doc(taskmodel.id);
    await docRef.delete();
  }

  // fetch task ids of the given user
  Future<List<String>> getTaskIdsFromUser(String id) async {
    List<String> taskIds = [];
    await db
        .collection("tasks")
        .where("ownerId",
            isEqualTo: id) // should be adjusted to include friends
        .get()
        .then((querySnapshot) {
      for (var docSnapshot in querySnapshot.docs) {
        taskIds.add(docSnapshot.id);
      }
    });

    return taskIds;
  }

  // fetch info about a particular task id
  Future<TaskModel?> getTaskInfo(String id) async {
    final docRef = db.collection("tasks").doc(id).withConverter(
        fromFirestore: TaskModel.fromFirestore,
        toFirestore: (TaskModel model, _) => model.toFirestore());
    final docSnap = await docRef.get();
    final taskmodel = docSnap.data();
    return taskmodel;
  }
}
