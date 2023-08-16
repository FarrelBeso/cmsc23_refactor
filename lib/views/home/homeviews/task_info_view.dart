import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_refactor/model/constants.dart';
import 'package:todo_refactor/model/task_model.dart';
import 'package:todo_refactor/provider/homepage_provider.dart';
import 'package:todo_refactor/provider/task_provider.dart';

class TaskInfoView extends StatefulWidget {
  const TaskInfoView({super.key});

  @override
  State<TaskInfoView> createState() => _TaskInfoViewState();
}

class _TaskInfoViewState extends State<TaskInfoView> {
  late TaskModel currentTask;
  @override
  Widget build(BuildContext context) {
    currentTask =
        Provider.of<TaskProvider>(context, listen: false).selectedTask!;
    return Expanded(child: _mainDisplayWidget());
  }

// the main component, call this when the future builder
  Widget _mainDisplayWidget() {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            color: Theme.of(context).primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24,
                ),
                _taskNameWidget(),
                _taskOwnerWidget(),
                SizedBox(
                  height: 8,
                ),
                Divider(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _statusWidget(),
                            SizedBox(
                              width: 20,
                            ),
                            _deadlineWidget()
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          _modifyWidget(),
          Divider(),
          _descriptionWidget()
        ],
      ),
    );
  }

  // components
  Widget _taskNameWidget() {
    return Text(
      currentTask.taskName!,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _taskOwnerWidget() {
    return Text(
      currentTask.ownerFullName!,
      style: TextStyle(fontSize: 16, color: Colors.white70),
    );
  }

  Widget _statusWidget() {
    TaskStatus taskstatus = TaskStatus.fetchFromName(currentTask.status!);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.all(5),
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: taskstatus.color, shape: BoxShape.circle),
          ),
          SizedBox(
            width: 8,
          ),
          Text(
            taskstatus.label,
            style: TextStyle(fontSize: 12),
          )
        ],
      ),
    );
  }

  Widget _deadlineWidget() {
    return Text(
      'Due ${_dateTimeFormat(currentTask.deadline!)}',
      style: TextStyle(color: Colors.white),
    );
  }

  Widget _descriptionWidget() {
    return Container(
      padding: EdgeInsets.all(16),
      alignment: Alignment.topLeft,
      child: Text(
        currentTask.description!,
        style: TextStyle(color: Colors.black45, fontSize: 14),
        textAlign: TextAlign.justify,
        maxLines: 16,
      ),
    );
  }

  Widget _modifyWidget() {
    return Container(
      padding: EdgeInsets.only(top: 16, bottom: 4, left: 16, right: 16),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last modified by',
                    style: TextStyle(fontSize: 10, color: Colors.black45),
                  ),
                  Text(
                    '${currentTask.lastEditFullName}, ${_dateTimeFormat(currentTask.lastEditedDate!)}',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
          IconButton.filledTonal(
              onPressed: () {
                // switch to edit mode
                Provider.of<HomepageProvider>(context, listen: false)
                    .setView(MainPageViews.taskEdit);
              },
              icon: Icon(Icons.edit))
        ],
      ),
    );
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

  // based on the date and time deadline
  String _dateTimeFormat(DateTime date) {
    // String to be appended
    String dateString = DateFormat.yMMMd().format(date);
    String timeString = DateFormat.jm().format(date);

    return '$dateString, $timeString';
  }
}
