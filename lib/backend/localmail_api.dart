import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_refactor/model/localmail_model.dart';
import 'package:todo_refactor/model/user_model.dart';

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
  final db = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  // add a mail
  Future<void> addMailToUser(String userId, LocalMailModel mail) async {
    final mailref = db
        .collection("localmails")
        .withConverter(
            fromFirestore: LocalMailModel.fromFirestore,
            toFirestore: (LocalMailModel model, options) => model.toFirestore())
        .doc(mail.id);
    await mailref.set(mail);

    //then reference it
    final userref = db.collection("users").doc(userId);
    await userref.update({
      "localMailIds": FieldValue.arrayUnion([mail.id])
    });
  }

  // fetch all mail from user
  Future<List<LocalMailModel>?> getLocalMailFromUser() async {
    List<LocalMailModel> mails = [];
    final mailIds = await getLocalMailIdsFromCurrentUser();

    await db
        .collection("localmails")
        .where("id", arrayContains: mailIds)
        .get()
        .then((querySnapshot) {
      for (var docSnapshot in querySnapshot.docs) {
        mails.add(LocalMailModel.fromFirestore(docSnapshot, null));
      }
    });

    return mails;
  }

  // fetch the ids of the mails of the current user
  Future<List<String>?> getLocalMailIdsFromCurrentUser() async {
    final docRef = db.collection("users").doc(_currentUser!.uid).withConverter(
        fromFirestore: UserModel.fromFirestore,
        toFirestore: (UserModel model, _) => model.toFirestore());
    final docSnap = await docRef.get();
    final usermodel = docSnap.data();

    return usermodel?.localMailIds;
  }
}
