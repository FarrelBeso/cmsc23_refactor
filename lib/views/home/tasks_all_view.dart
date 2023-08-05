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

  // mock data
  static const List titles = ['Task A', 'Task B', 'Task C'];
  static const List status = [
    'Not Started',
    'Working',
    'Done',
    'Late',
    'Done Late'
  ];
  static const List statusColors = [
    Colors.black45,
    Colors.yellow,
    Colors.green,
    Colors.red,
    Colors.orange
  ];

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
          Expanded(
            child: ListView.separated(
                padding: EdgeInsets.all(16),
                itemCount: 15,
                separatorBuilder: (context, index) {
                  return Divider();
                },
                itemBuilder: (BuildContext context, int index) {
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
                                titles[Random().nextInt(3)],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Text(
                                'First Last',
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
                                      color: statusColors[Random().nextInt(5)],
                                      shape: BoxShape.circle),
                                ),
                                Text(status[Random().nextInt(5)]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
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
    if (!res.success) print(res.message);
    for (TaskModel task in res.content) {
      // also fetch the name while at it
      res = await UserUtils().getUser(task.ownerId!);
      String name = res.success ? (res.content as UserModel).username! : 'N/A';
      // then finally add all of them to the cardlist
      cardlist.add(_CardInfo(
          taskName: task.taskName,
          taskOwner: name,
          taskStatus: TaskStatus.fetchFromName(task.status!)));
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
