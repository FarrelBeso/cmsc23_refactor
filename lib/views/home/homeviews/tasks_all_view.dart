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
  @override
  Widget build(BuildContext context) {
    // create 15 random tasks

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.search,
                      size: 32,
                    ))
              ],
            ),
          ),
          Divider(),
          _futureBuilderWrapper()
        ],
      ),
    );
  }

  // future builder wrapper
  Widget _futureBuilderWrapper() {
    return FutureBuilder(
        future: _cardInfoList(),
        builder: ((context, snapshot) {
          Widget content;
          // what would be on it?
          if (snapshot.hasData) {
            if (snapshot.data!.isNotEmpty) {
              content = _taskListWidget(snapshot.data!);
            } else {
              content = _emptyListWidget();
            }
          } else if (snapshot.hasError) {
            content = _errorWidget();
          } else {
            content = _loadingWidget();
          }
          return Expanded(child: content);
        }));
  }

  // the info list
  Widget _taskListWidget(List<_CardInfo> cardinfolist) {
    return ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: cardinfolist.length,
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemBuilder: (BuildContext context, int index) {
          _CardInfo cardinfo = cardinfolist[index];
          return InkWell(
            onTap: () {
              // switch to task info
              Provider.of<HomepageProvider>(context, listen: false)
                  .setArgument(cardinfo.taskModel);
              Provider.of<HomepageProvider>(context, listen: false)
                  .setView(MainPageViews.taskInfo);
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
                        cardinfo.taskModel!.taskName!,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        cardinfo.taskOwner!,
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
                              color: cardinfo.taskStatus!.color,
                              shape: BoxShape.circle),
                        ),
                        Text(cardinfo.taskStatus!.label),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
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

  // fetch card info list
  Future<List<_CardInfo>?> _cardInfoList() async {
    // first get the list
    List<_CardInfo>? cardlist;
    List<TaskModel>? tasklist = await _getTaskListWrapper();

    if (tasklist != null) {
      cardlist = [];
      for (TaskModel task in tasklist) {
        // then finally add all of them to the cardlist
        cardlist.add(_CardInfo(
            taskModel: task,
            taskOwner: _fullName(),
            taskStatus: TaskStatus.fetchFromName(task.status!)));
      }
    }

    return cardlist;
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
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(res.message!)));
        }
      }
    }
    return tasklist;
  }

  // wrapper for getting the full name
  String _fullName() {
    UserModel user = Provider.of<AuthProvider>(context).user!;
    return '${user.firstName} ${user.lastName}';
  }
}

// temp class to store card info
class _CardInfo {
  TaskModel? taskModel;
  String? taskOwner;
  TaskStatus? taskStatus;

  _CardInfo(
      {required this.taskModel,
      required this.taskOwner,
      required this.taskStatus});
}
