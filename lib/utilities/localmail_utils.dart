import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_refactor/backend/localmail_api.dart';
import 'package:todo_refactor/model/localmail_model.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/task_model.dart';
import 'package:todo_refactor/model/user_model.dart';

import '../backend/api_setting.dart';

class LocalMailUtils {
  final db = currentFirebase;

  // the mail would be broadcasted
  Future<ResponseModel> addMailToUsers(
      List<String> userIdList, LocalMailModel mail) async {
    try {
      ResponseModel res;
      for (var id in userIdList) {
        res = await LocalMailAPI().addMailToUser(id, mail);
        if (!res.success) throw Error;
      }
      return ResponseModel(success: true, message: 'Local mail sent.');
    } catch (e) {
      return ResponseModel(
          success: false, message: 'Failed to send all local mail.');
    }
  }

  Future<ResponseModel> getLocalMailFromUser() async {
    return await LocalMailAPI().getLocalMailFromUser();
  }

  // wrapper for mails
  LocalMailModel editMail(String id, TaskModel prevTask, TaskModel task) {
    return LocalMailModel(
        id: id,
        type: 'edit',
        message:
            'The task ${prevTask.taskName} has recently been edited by ${task.lastEditFullName}. See task for full details.',
        timestamp: DateTime.now());
  }

  LocalMailModel deleteMail(String id, TaskModel prevTask, TaskModel task) {
    return LocalMailModel(
        id: id,
        type: 'delete',
        message:
            'The task ${task.taskName} has recently been deleted by ${task.lastEditFullName}.',
        timestamp: DateTime.now());
  }

  LocalMailModel requestPendingMail(String id, UserModel sender) {
    return LocalMailModel(
        id: id,
        type: 'request_pending',
        message:
            '${sender.firstName} ${sender.lastName} (${sender.username}) has sent you a friend request. See your profile for more details.',
        timestamp: DateTime.now());
  }

  LocalMailModel requestConfirmMail(String id, UserModel respondent) {
    return LocalMailModel(
        id: id,
        type: 'request_pending',
        message:
            '${respondent.firstName} ${respondent.lastName} (${respondent.username}) has accepted your friend request.',
        timestamp: DateTime.now());
  }

  // this is for local mail construction
  Icon mailIcon(LocalMailModel mail) {
    switch (mail.type) {
      case 'edit':
        return Icon(Icons.edit);
      case 'delete':
        return Icon(Icons.delete_forever);
      case 'request_pending':
        return Icon(Icons.person_add);
      case 'request_confirm':
        return Icon(Icons.people);
      default:
        return Icon(Icons.notifications);
    }
  }
}
