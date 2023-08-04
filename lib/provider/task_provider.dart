import 'package:flutter/material.dart';
import 'package:todo_refactor/backend/auth_api.dart';
import 'package:todo_refactor/backend/tasks_api.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/task_model.dart';

class TaskProvider extends ChangeNotifier {
  Future<ResponseModel> addTask(TaskModel taskmodel) async {
    ResponseModel response =
        ResponseModel(success: true, message: 'Task added'); // default value
    await TasksAPI()
        .addTask(taskmodel)
        .then((value) => AuthAPI().addTaskId(taskmodel.id!))
        .onError((error, stackTrace) {
      print(error);
      response = ResponseModel(success: false, message: 'Failed to add task');
    });
    return response;
  }
}
