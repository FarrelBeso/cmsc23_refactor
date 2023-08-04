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
}
