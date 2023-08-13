import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_refactor/model/user_model.dart';

class UserAPI {
  final db = FirebaseFirestore.instance;
  User? get currentUser => FirebaseAuth.instance.currentUser;

  // get the user info
  Future<UserModel?> getUser(String id) async {
    final docRef = db.collection("users").doc(id).withConverter(
        fromFirestore: UserModel.fromFirestore,
        toFirestore: (UserModel model, _) => model.toFirestore());
    final docSnap = await docRef.get();
    final usermodel = docSnap.data();
    return usermodel;
  }

  // update that the user has a new task that they made
  Future<void> addTaskId(String taskId) async {
    final docRef = db.collection("users").doc(currentUser!.uid);
    await docRef.update({
      "taskOwnIds": FieldValue.arrayUnion([taskId])
    });
  }

  // remove the task from id
  Future<void> removeTaskId(String taskId) async {
    final docRef = db.collection("users").doc(currentUser!.uid);
    await docRef.update({
      "taskOwnIds": FieldValue.arrayRemove([taskId])
    });
  }
}
