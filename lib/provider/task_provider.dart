import 'package:flutter/foundation.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/task_model.dart';
import 'package:todo_refactor/utilities/task_utils.dart';

class TaskProvider extends ChangeNotifier {
  List<TaskModel>? currentTaskList;

  List<TaskModel>? get tasklist => currentTaskList;

  // the task that was recently selected
  TaskModel? recentlySelectedTask;

  TaskModel? get selectedTask => recentlySelectedTask;

  void setTaskList(List<TaskModel> tasklist) {
    currentTaskList = tasklist;
    notifyListeners();
  }

  void clearTaskList() {
    currentTaskList = null;
    notifyListeners();
  }

  void setSelectedTask(TaskModel task) {
    recentlySelectedTask = task;
    notifyListeners();
  }

  void clearSelectedTask() {
    recentlySelectedTask = null;
    notifyListeners();
  }

  // wrappers

  /*
  Used when the current task list is to be initialized
  or updated if it deviated a lot
  */
  Future<ResponseModel> updateTaskList() async {
    ResponseModel res = await TaskUtils().getTaskList();
    // additional portion
    if (res.success) {
      setTaskList(res.content);
    }
    return res;
  }

  // simplest approach, update when there are changes
  Future<ResponseModel> addTask(TaskModel taskModel) async {
    ResponseModel res;
    res = await TaskUtils().addTask(taskModel);
    // additional portion
    if (res.success) {
      res = await updateTaskList();
    }
    return res;
  }

  Future<ResponseModel> updateTask(TaskModel taskModel) async {
    ResponseModel res;
    res = await TaskUtils().updateTask(taskModel);
    // additional portion
    if (res.success) {
      res = await updateTaskList();
    }
    return res;
  }

  Future<ResponseModel> removeTask(TaskModel taskModel) async {
    ResponseModel res;
    res = await TaskUtils().removeTask(taskModel);
    // additional portion
    if (res.success) {
      res = await updateTaskList();
    }
    return res;
  }
}
