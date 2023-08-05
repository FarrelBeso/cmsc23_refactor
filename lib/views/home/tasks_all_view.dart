import 'dart:math';

import 'package:flutter/material.dart';
import 'package:todo_refactor/model/constants.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/task_model.dart';
import 'package:todo_refactor/model/user_model.dart';
import 'package:todo_refactor/utilities/task_utils.dart';
import 'package:todo_refactor/utilities/user_utils.dart';

class TasksView extends StatelessWidget {
  const TasksView({super.key});

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
            onTap: () {},
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
                        cardinfo.taskName!,
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
  Future<List<_CardInfo>> _cardInfoList() async {
    ResponseModel res;
    // first get the list
    List<_CardInfo> cardlist = [];
    res = await TaskUtils().getTaskList();
    if (!res.success) {
      print(res.message);
    } else {
      for (TaskModel task in res.content) {
        // also fetch the name while at it
        res = await UserUtils().getUser(task.ownerId!);
        String fullname;
        if (res.success) {
          UserModel user = res.content;
          fullname = '${user.firstName} ${user.lastName}';
        } else {
          fullname = 'N/A';
        }

        // then finally add all of them to the cardlist
        cardlist.add(_CardInfo(
            taskName: task.taskName,
            taskOwner: fullname,
            taskStatus: TaskStatus.fetchFromName(task.status!)));
      }
    }

    return cardlist;
  }
}

// temp class to store card info
class _CardInfo {
  String? taskName;
  String? taskOwner;
  TaskStatus? taskStatus;

  _CardInfo({this.taskName, this.taskOwner, this.taskStatus});
}
