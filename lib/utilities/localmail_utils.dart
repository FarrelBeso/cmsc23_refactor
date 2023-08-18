import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_refactor/backend/auth_api.dart';
import 'package:todo_refactor/backend/localmail_api.dart';
import 'package:todo_refactor/model/localmail_model.dart';
import 'package:todo_refactor/model/response_model.dart';

class LocalMailUtils {
  final db = FirebaseFirestore.instance;

  Future<ResponseModel> addMailToUser(
      String userId, LocalMailModel mail) async {
    try {
      await LocalMailAPI().addMailToUser(userId, mail);
      return ResponseModel(success: true, message: 'Local mail sent');
    } catch (e) {
      print(e);
    }
    return ResponseModel(success: false, message: 'Failed to send local mail');
  }

  Future<ResponseModel> getLocalMailFromUser() async {
    try {
      final mails = await LocalMailAPI().getLocalMailFromUser();
      return ResponseModel(success: true, content: mails);
    } catch (e) {
      print(e);
    }
    return ResponseModel(success: false, message: 'Failed to fetch mails');
  }
}
