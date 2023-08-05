import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_refactor/model/user_model.dart';

class UserAPI {
  final db = FirebaseFirestore.instance;

  // get the user info
  Future<UserModel?> getUser(String id) async {
    final docRef = db.collection("users").doc(id).withConverter(
        fromFirestore: UserModel.fromFirestore,
        toFirestore: (UserModel model, _) => model.toFirestore());
    final docSnap = await docRef.get();
    final usermodel = docSnap.data();
    return usermodel;
  }
}
