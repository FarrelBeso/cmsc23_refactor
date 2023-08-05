import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_refactor/model/constants.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/task_model.dart';
import 'package:todo_refactor/model/user_model.dart';
import 'package:todo_refactor/provider/homepage_provider.dart';
import 'package:todo_refactor/utilities/auth_utils.dart';
import 'package:todo_refactor/utilities/task_utils.dart';
import 'package:uuid/uuid.dart';

class TaskInfoView extends StatefulWidget {
  const TaskInfoView({super.key});

  @override
  State<TaskInfoView> createState() => _TaskInfoViewState();
}

class _TaskInfoViewState extends State<TaskInfoView> {
  @override
  Widget build(BuildContext context) {
    return Expanded(child: child);
  }

// the main component, call this when the future builder
// has been loaded
  Widget _mainDisplayWidget(_TaskInfo taskinfo) {
    // parse info
    TaskModel taskmodel = taskinfo.taskmodel!;
    String ownerFullName = taskinfo.ownerFullName!;
    String lastEditorFullName = taskinfo.lastEditorFullName!;

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
                _taskNameWidget(taskmodel.taskName!),
                _taskOwnerWidget(ownerFullName),
                Divider(),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _statusWidget(taskmodel.status!),
                            SizedBox(
                              width: 20,
                            ),
                            _deadlineWidget(taskmodel.deadline!)
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          _modifyWidget(lastEditorFullName, taskmodel.lastEditedDate!),
          Divider(),
          _descriptionWidget(taskmodel.description!)
        ],
      ),
    );
  }

  // components
  Widget _taskNameWidget(String name) {
    return Text(
      name,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _taskOwnerWidget(String name) {
    return Text(
      name,
      style: TextStyle(fontSize: 16, color: Colors.white70),
    );
  }

  Widget _statusWidget(String status) {
    TaskStatus taskstatus = TaskStatus.fetchFromName(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
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
            width: 16,
          ),
          Text(
            taskstatus.label,
            style: TextStyle(fontSize: 16),
          )
        ],
      ),
    );
  }

  Widget _deadlineWidget(DateTime deadline) {
    return Text(
      _dateTimeFormat(deadline!),
      style: TextStyle(color: Colors.white),
    );
  }

  Widget _descriptionWidget(String description) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Text(
        description,
        style: TextStyle(color: Colors.black45, fontSize: 14),
        maxLines: 16,
      ),
    );
  }

  Widget _modifyWidget(String lastEditorFullName, DateTime lastEditDate) {
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
                    '$lastEditorFullName, ${_dateTimeFormat(lastEditDate)}',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
          IconButton.filledTonal(onPressed: () {}, icon: Icon(Icons.edit))
        ],
      ),
    );
  }

  // other aux functions
  // based on the date and time deadline
  String _dateTimeFormat(DateTime date) {
    // String to be appended
    String dateString = DateFormat.yMMMd().format(date);
    String timeString = DateFormat.jm().format(date);

    return '$dateString, $timeString';
  }
}

// temp class for passing argument to the main display
class _TaskInfo {
  TaskModel? taskmodel;
  String? ownerFullName;
  String? lastEditorFullName;

  _TaskInfo(
      {required this.taskmodel,
      required this.ownerFullName,
      required this.lastEditorFullName});
}
