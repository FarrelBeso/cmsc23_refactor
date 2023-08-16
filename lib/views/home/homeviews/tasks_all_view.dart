import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_refactor/model/constants.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/task_model.dart';
import 'package:todo_refactor/model/user_model.dart';
import 'package:todo_refactor/provider/auth_provider.dart';
import 'package:todo_refactor/provider/homepage_provider.dart';
import 'package:todo_refactor/provider/task_provider.dart';

class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  // the search query
  String searchQuery = '';
  // the whole list to be loaded
  List<TaskModel>? currentLoadResult;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [_searchBar()],
            ),
          ),
          Divider(),
          _contentWrapper()
        ],
      ),
    );
  }

  // the main search bar
  Widget _searchBar() {
    return SearchBar(
      onChanged: (value) {
        searchQuery = value;
      },
    );
  }

  // wrapper on the overall content
  Widget _contentWrapper() {
    if (currentLoadResult == null) {
      return _futureBuilderWrapper();
    } else {
      // filter the tasklist here
      List<TaskModel> tasklist = _searchFilter();
      return _taskListWidget(tasklist);
    }
  }

  // the filter function based on the
  // current load result
  List<TaskModel> _searchFilter() {
    return currentLoadResult!.where((task) =>
        ((task.taskName)!.contains(searchQuery)) ||
        ((task.status)!.contains(searchQuery))) as List<TaskModel>;
  }

  // future builder wrapper
  Widget _futureBuilderWrapper() {
    return FutureBuilder(
        future: _getTaskListWrapper(),
        builder: ((context, snapshot) {
          Widget content;
          // what would be on it?
          if (snapshot.hasData) {
            if (snapshot.data!.isNotEmpty) {
              content = _taskListWidget(snapshot.data!);
            } else {
              content = _emptyListWidget();
            }
            // assign the data here
            currentLoadResult = snapshot.data!;
          } else if (snapshot.hasError) {
            content = _errorWidget();
          } else {
            content = _loadingWidget();
          }
          return Expanded(child: content);
        }));
  }

  // the info list
  Widget _taskListWidget(List<TaskModel> tasklist) {
    return ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: tasklist.length,
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemBuilder: (BuildContext context, int index) {
          TaskModel task = tasklist[index];
          TaskStatus status = TaskStatus.fetchFromName(task.status!);
          return InkWell(
            onTap: () {
              // switch to task info
              _viewTaskWrapper(task);
            },
            child: Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.taskName!,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        task.ownerFullName!,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  )),
                  Container(
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.all(5),
                          width: 10.0,
                          height: 10.0,
                          decoration: BoxDecoration(
                              color: status.color, shape: BoxShape.circle),
                        ),
                        Text(status.label),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  // wrapper to view the task
  void _viewTaskWrapper(TaskModel task) {
    // set the task first
    Provider.of<TaskProvider>(context, listen: false).setSelectedTask(task);

    Provider.of<HomepageProvider>(context, listen: false)
        .setView(MainPageViews.taskInfo);
  }

  Widget _errorWidget() {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 24,
          ),
          Text(
            'Failed to fetch data',
            style: TextStyle(fontSize: 20),
          )
        ],
      ),
    );
  }

  Widget _loadingWidget() {
    return Center(
      child: SizedBox(
        width: 60,
        height: 60,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _emptyListWidget() {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 24,
          ),
          Text(
            'No tasks to show',
            style: TextStyle(fontSize: 20),
          )
        ],
      ),
    );
  }

  // wrapper for calling the async task list
  Future<List<TaskModel>?> _getTaskListWrapper() async {
    // only reload if the current is null
    List<TaskModel>? tasklist =
        Provider.of<TaskProvider>(context, listen: false).tasklist;
    if (tasklist == null) {
      ResponseModel res =
          await Provider.of<TaskProvider>(context, listen: false)
              .updateTaskList();
      if (context.mounted) {
        if (res.success) {
          // reupdate the tasklist
          tasklist = Provider.of<TaskProvider>(context, listen: false).tasklist;
        } else {
          // ScaffoldMessenger.of(context)
          //     .showSnackBar(SnackBar(content: Text(res.message!)));
        }
      }
    }
    return tasklist;
  }
}
