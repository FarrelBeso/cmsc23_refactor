import 'package:todo_refactor/backend/auth_api.dart';
import 'package:todo_refactor/backend/tasks_api.dart';
import 'package:todo_refactor/backend/user_api.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/task_model.dart';
import 'package:todo_refactor/model/user_model.dart';

class TaskUtils {
  Future<ResponseModel> addTask(TaskModel taskmodel) async {
    ResponseModel response =
        ResponseModel(success: true, message: 'Task added'); // default value
    await TasksAPI()
        .addTask(taskmodel)
        .then((value) => UserAPI().addTaskId(taskmodel.id!))
        .onError((error, stackTrace) {
      print(error);
      response = ResponseModel(success: false, message: 'Failed to add task');
    });
    return response;
  }

// practically the same as add task
  Future<ResponseModel> updateTask(TaskModel taskmodel) async {
    ResponseModel response = ResponseModel(
        success: true, message: 'Task updated successfully'); // default value
    await TasksAPI().updateTask(taskmodel).onError((error, stackTrace) {
      print(error);
      response =
          ResponseModel(success: false, message: 'Failed to update task');
    });
    return response;
  }

  Future<ResponseModel> removeTask(TaskModel taskModel) async {
    ResponseModel response =
        ResponseModel(success: true, message: 'Task deleted successfully');
    await TasksAPI()
        .removeTask(taskModel)
        .then((value) => UserAPI().removeTaskId(taskModel.id!))
        .onError((error, stackTrace) {
      print(error);
      response =
          ResponseModel(success: false, message: 'Failed to delete task');
    });
    return response;
  }

  // fetch tasks including your friends'
  Future<ResponseModel> getTaskListFromUser() async {
    try {
      List<TaskModel> tasklist = [];
      // get the current user
      UserModel? currentuser = await AuthAPI().getCurrentUser();
      if (currentuser == null) throw 'Failed to fetch current user';
      // first fetch the tasklist of the user themselves
      final res = await getTaskList(currentuser.id!);
      tasklist.addAll(res.content);
      // then the rest of the user's friends
      for (var friendid in currentuser.friendIds!) {
        final res = await getTaskList(friendid);
        tasklist.addAll(res.content);
      }
      return ResponseModel(
          success: true,
          message: 'Tasks successfully retrieved',
          content: tasklist);
    } catch (error) {
      print(error);
      return ResponseModel(success: false, message: 'Failed to fetch data');
    }
  }

  // get tasklist of users
  Future<ResponseModel> getTaskList(String userId) async {
    List<TaskModel> tasklist = [];
    List<String> taskIds = await TasksAPI().getTaskIdsFromUser(userId);

    for (var id in taskIds) {
      TaskModel? task = await TasksAPI().getTaskInfo(id);
      if (task == null) {
        // set it up
        print('Failed to fetch a task');
      } else {
        tasklist.add(task);
      }
    }

    return ResponseModel(success: true, content: tasklist);
  }

  // get task info of one task
  Future<ResponseModel> getTaskFromId(String id) async {
    try {
      TaskModel? task = await TasksAPI().getTaskInfo(id);
      if (task == null) throw 'Failed to fetch task';

      return ResponseModel(success: true, content: task);
    } catch (e) {
      print(e);
    }
    return ResponseModel(success: false);
  }
}
