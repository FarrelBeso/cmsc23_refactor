import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_refactor/model/localmail_model.dart';

class LocalMailAPI {
  final db = FirebaseFirestore.instance;

  // add a mail
  Future<void> addMailToUser(String userId, LocalMailModel mail) async {
    final mailref = db
        .collection("localmails")
        .withConverter(
            fromFirestore: LocalMailModel.fromFirestore,
            toFirestore: (LocalMailModel model, options) => model.toFirestore())
        .doc(mail.id);
    await mailref.set(mail);

    // then reference it
    final userref = db.collection("users").doc(userId);
    await userref.update({
      "localMailIds": FieldValue.arrayUnion([mail.id])
    });
  }

  // fetch all mail from user
  Future<List<LocalMailModel>> getLocalMailFromUser(String id) async {
    List<LocalMailModel> mails = [];
    await db
        .collection("localmails")
        .where("userId", isEqualTo: id)
        .get()
        .then((querySnapshot) {
      for (var docSnapshot in querySnapshot.docs) {
        mails.add(LocalMailModel.fromFirestore(docSnapshot, null));
      }
    });

    return mails;
  }
}
