import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_refactor/model/constants.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/task_model.dart';
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
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [_searchBar()],
            ),
          ),
          const Divider(),
          _contentWrapper()
        ],
      ),
    );
  }

  // the main search bar
  Widget _searchBar() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.all(8),
        child: SearchBar(
          trailing: [
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: const Icon(Icons.search))
          ],
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
        ),
      ),
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
    // manual filtering

    if (searchQuery.isEmpty) {
      return currentLoadResult!;
    } else {
      List<TaskModel> list = [];
      String lowersearch = searchQuery.toLowerCase();
      for (var task in currentLoadResult!) {
        if (!(list.contains(task)) &&
            ((task.taskName!.toLowerCase()).contains(lowersearch) ||
                (task.status!.toLowerCase()).contains(lowersearch))) {
          list.add(task);
        }
      }
      return list;
    }
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
        padding: const EdgeInsets.all(16),
        itemCount: tasklist.length,
        separatorBuilder: (context, index) {
          return const Divider();
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
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.taskName!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        task.ownerFullName!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  )),
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(5),
                        width: 10.0,
                        height: 10.0,
                        decoration: BoxDecoration(
                            color: status.color, shape: BoxShape.circle),
                      ),
                      Text(status.label),
                    ],
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
    return const Center(
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
    return const Center(
      child: SizedBox(
        width: 60,
        height: 60,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _emptyListWidget() {
    return const Center(
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
          // also update the state
          setState(() {
            currentLoadResult = tasklist;
          });
        } else {
          // ScaffoldMessenger.of(context)
          //     .showSnackBar(SnackBar(content: Text(res.message!)));
        }
      }
    }
    return tasklist;
  }
}
