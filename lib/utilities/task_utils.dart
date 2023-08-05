import 'package:todo_refactor/backend/auth_api.dart';
import 'package:todo_refactor/backend/tasks_api.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/task_model.dart';

class TaskUtils {
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

  // get list of tasks
  Future<ResponseModel> getTaskList() async {
    ResponseModel response = ResponseModel(success: true); // default
    List<TaskModel> tasklist = [];
    List<String> taskIds =
        await TasksAPI().getTaskIdsFromUser(AuthAPI().currentUser!.uid);

    for (var id in taskIds) {
      TaskModel? task = await TasksAPI().getTaskInfo(id);
      if (task == null) {
        // set it up
        response =
            ResponseModel(success: false, message: 'Failed to fetch all tasks');
      } else {
        tasklist.add(task);
      }
    }

    response.content = tasklist;
    return response;
  }
}
