import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_refactor/model/localmail_model.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/user_model.dart';

import 'api_setting.dart';

class LocalMailAPI {
  /*  
    LocalMails are emails for the app
    This would trigger on the following circumstances
    Task Related:
    - task is edited
    - task is deleted
    User Related:
    - friend request from others
    - friend request confirmed
  */
  final db = currentFirebase;
  final _currentUser = currentAuth.currentUser;

  // add a mail
  Future<ResponseModel> addMailToUser(
      String userId, LocalMailModel mail) async {
    try {
      final mailref = db
          .collection("localmails")
          .withConverter(
              fromFirestore: LocalMailModel.fromFirestore,
              toFirestore: (LocalMailModel model, options) =>
                  model.toFirestore())
          .doc(mail.id);
      await mailref.set(mail);

      //then reference it
      final userref = db.collection("users").doc(userId);
      await userref.update({
        "localMailIds": FieldValue.arrayUnion([mail.id])
      });
      return ResponseModel(success: true, message: 'Mail added to user.');
    } catch (e) {
      return ResponseModel(
          success: false, message: 'Failed to add mail to user.');
    }
  }

  // fetch all mail from user
  Future<ResponseModel> getLocalMailFromUser() async {
    try {
      List<LocalMailModel> mails = [];
      final res = await getLocalMailIdsFromCurrentUser();
      if (!res.success) throw Error;
      final mailIds = res.content;

      await db
          .collection("localmails")
          .where("id", whereIn: mailIds)
          //.orderBy("createdAt", descending: true)
          .get()
          .then((querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          mails.add(LocalMailModel.fromFirestore(docSnapshot, null));
        }
      });
      return ResponseModel(
          success: true, message: 'Local mails fetched.', content: mails);
    } catch (e) {
      return ResponseModel(
          success: false, message: 'Failed to fetch local mails.');
    }
  }

  // fetch the ids of the mails of the current user
  Future<ResponseModel> getLocalMailIdsFromCurrentUser() async {
    try {
      final docRef = db
          .collection("users")
          .doc(_currentUser!.uid)
          .withConverter(
              fromFirestore: UserModel.fromFirestore,
              toFirestore: (UserModel model, _) => model.toFirestore());
      final docSnap = await docRef.get();
      final usermodel = docSnap.data();

      return ResponseModel(
          success: true,
          message: 'Local mail ids from current user fetched',
          content: usermodel?.localMailIds);
    } catch (e) {
      return ResponseModel(
          success: false,
          message: 'Failed to fetch local mail ids from current user.');
    }
  }
}
