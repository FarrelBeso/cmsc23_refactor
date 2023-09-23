import 'package:todo_refactor/backend/auth_api.dart';
import 'package:todo_refactor/backend/tasks_api.dart';
import 'package:todo_refactor/backend/user_api.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/task_model.dart';
import 'package:todo_refactor/model/user_model.dart';

class TaskUtils {
  Future<ResponseModel> addTask(TaskModel taskmodel) async {
    try {
      ResponseModel res;
      res = await TasksAPI().addTask(taskmodel);
      if (!res.success) throw Error;
      res = await UserAPI().addTaskId(taskmodel.id!);
      if (!res.success) throw Error;
      return ResponseModel(success: true, message: 'Task added.');
    } catch (e) {
      return ResponseModel(success: false, message: 'Failed to add task.');
    }
  }

// practically the same as add task
  Future<ResponseModel> updateTask(TaskModel taskmodel) async {
    return await TasksAPI().updateTask(taskmodel);
  }

  Future<ResponseModel> removeTask(TaskModel taskModel) async {
    try {
      ResponseModel res;
      res = await TasksAPI().removeTask(taskModel);
      if (!res.success) throw Error;
      res = await UserAPI().removeTaskId(taskModel.id!);
      if (!res.success) throw Error;
      return ResponseModel(
          success: true, message: 'Task deleted successfully.');
    } catch (e) {
      return ResponseModel(success: false, message: 'Failed to delete task.');
    }
  }

  // fetch tasks including your friends'
  Future<ResponseModel> getTaskListFromUser() async {
    try {
      ResponseModel res;
      List<TaskModel> tasklist = [];
      // get the current user
      res = await AuthAPI().getCurrentUser();
      if (!res.success) throw Error;
      UserModel currentuser = res.content;
      // first fetch the tasklist of the user themselves
      res = await getTaskList(currentuser.id!);
      if (!res.success) throw Error;
      List<TaskModel> list = res.content;
      tasklist.addAll(list);
      // then the rest of the user's friends
      for (var friendid in currentuser.friendIds!) {
        res = await getTaskList(friendid);
        if (!res.success) throw Error;
        List<TaskModel> list = res.content;
        tasklist.addAll(list);
      }
      return ResponseModel(
          success: true,
          message: 'Tasks successfully retrieved',
          content: tasklist);
    } catch (error) {
      return ResponseModel(success: false, message: 'Failed to fetch data');
    }
  }

  // get tasklist of users
  Future<ResponseModel> getTaskList(String userId) async {
    try {
      ResponseModel res;
      List<TaskModel> tasklist = [];
      res = await TasksAPI().getTaskIdsFromUser(userId);
      if (!res.success) throw Error;
      List<String> taskIds = res.content;

      for (var id in taskIds) {
        res = await TasksAPI().getTaskInfo(id);
        if (!res.success) throw Error;
        TaskModel task = res.content;
        tasklist.add(task);
      }

      return ResponseModel(
          success: true, message: 'Task list fetched.', content: tasklist);
    } catch (e) {
      return ResponseModel(
          success: false, message: 'Failed to fetch task list.');
    }
  }

  // get task info of one task
  Future<ResponseModel> getTaskFromId(String id) async {
    try {
      ResponseModel res;
      res = await TasksAPI().getTaskInfo(id);
      if (!res.success) throw Error;
      TaskModel task = res.content;

      return ResponseModel(
          success: true, message: 'Fetched task from id.', content: task);
    } catch (e) {
      return ResponseModel(
          success: false, message: 'Failed to fetch task from id.');
    }
  }
}
