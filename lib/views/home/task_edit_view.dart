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

class TaskEditView extends StatefulWidget {
  const TaskEditView({super.key});

  @override
  State<TaskEditView> createState() => _TaskEditViewState();
}

class _TaskEditViewState extends State<TaskEditView> {
  // should be supplied current info
  TextEditingController nameController = TextEditingController();
  TaskStatus currentStatus = TaskStatus.notStarted;
  DateTime currentDeadline = DateTime.now();
  TextEditingController descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final List<DropdownMenuItem<TaskStatus>> taskStatusEntries =
      <DropdownMenuItem<TaskStatus>>[];

  @override
  Widget build(BuildContext context) {
    // build the dropdown items here
    for (final TaskStatus status in TaskStatus.values) {
      if (status.selectable) {
        taskStatusEntries.add(DropdownMenuItem<TaskStatus>(
          value: status,
          child: Container(
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.all(5),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: status.color, shape: BoxShape.circle),
                ),
                SizedBox(
                  width: 16,
                ),
                Text(
                  status.label,
                  style: TextStyle(fontSize: 16),
                )
              ],
            ),
          ),
        ));
      }
    }

    //
    return Form(
      key: _formKey,
      child: Expanded(
          child: Container(
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
                  _taskNameEdit(),
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
                              _taskStatusEdit(),
                              SizedBox(
                                width: 20,
                              ),
                              _deadlineEdit()
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Divider(),
            _descriptionEdit(),
            Divider(),
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton.filled(
                      onPressed: () {
                        // send the new task
                        if (_formKey.currentState!.validate()) {
                          _addTaskWrapper();
                        }
                      },
                      icon: Icon(Icons.check)),
                  SizedBox(
                    width: 16,
                  ),
                  IconButton.outlined(
                      onPressed: () {
                        // return back to home
                        Provider.of<HomepageProvider>(context, listen: false)
                            .setView(MainPageViews.taskAll);
                      },
                      icon: Icon(Icons.close))
                ],
              ),
            )
          ],
        ),
      )),
    );
  }

  // widgets
  Widget _taskNameEdit() {
    return TextFormField(
      controller: nameController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Title is required';
        }
        return null;
      },
      cursorColor: Colors.white,
      decoration: InputDecoration(
        border: InputBorder.none,
        labelText: 'Task Name',
        labelStyle: TextStyle(color: Colors.white60),
        errorStyle: TextStyle(color: Colors.white70),
      ),
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _taskStatusEdit() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: DropdownButton(
          value: currentStatus,
          items: taskStatusEntries,
          underline: Container(),
          onChanged: (value) {
            setState(() {
              currentStatus = value!;
            });
          }),
    );
  }

  Widget _deadlineEdit() {
    return OutlinedButton(
      onPressed: () {
        _dateTimeSelectWrapper(context);
      },
      child: Text(
        _dateTimeFormat(),
        style: TextStyle(color: Colors.white),
      ),
      style: ButtonStyle(
          side: MaterialStatePropertyAll(BorderSide(color: Colors.white60))),
    );
  }

  Widget _descriptionEdit() {
    return Container(
      padding: EdgeInsets.all(16),
      child: TextFormField(
        controller: descriptionController,
        decoration: InputDecoration(
            hintText: 'Task Description (optional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
        style: TextStyle(color: Colors.black45, fontSize: 14),
        keyboardType: TextInputType.multiline,
        maxLines: 16,
      ),
    );
  }
  // useful functions

  // wrapper for adding the tasks
  Future<void> _addTaskWrapper() async {
    // first set the task model
    await _setNewTask().then((task) {
      if (task == null) throw 'Task Creation Failed';
      return TaskUtils().addTask(task);
    }).then((res) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res.message!)));
      if (res.success) _resetTextFields();
    }).onError((error, stackTrace) {
      print(error);
    });
  }

  void _resetTextFields() {
    nameController.clear();
    descriptionController.clear();
  }

  // transform the input
  Future<TaskModel?> _setNewTask() async {
    TaskModel? task;
    // set the task
    String id = Uuid().v4();
    // fetch the current user
    ResponseModel res = await AuthUtils().fetchCurrentUser();
    if (res.success) {
      task = TaskModel(
        id: id,
        taskName: nameController.text,
        status: currentStatus.label,
        deadline: currentDeadline,
        description: descriptionController.text,
        // misc info
        ownerId: (res.content as UserModel).id,
        lastEditedDate: DateTime.now(),
        lastEditUserId: (res.content as UserModel).id,
      );
    }

    return task;
  }

  Future<void> _dateTimeSelectWrapper(BuildContext context) async {
    await _selectDate(context);
    if (context.mounted) await _selectTime(context);
  }

  // based on the date and time deadline
  String _dateTimeFormat() {
    // String to be appended
    String dateString = DateFormat.yMMMd().format(currentDeadline);
    String timeString = DateFormat.jm().format(currentDeadline);

    return '$dateString, $timeString';
  }

  // converters
  TimeOfDay _getDeadlineTime() {
    return TimeOfDay.fromDateTime(currentDeadline);
  }

  // set only the date
  void _setDeadlineDate(DateTime datetime) {
    currentDeadline = DateTime(datetime.year, datetime.month, datetime.day,
        currentDeadline.hour, currentDeadline.minute);
  }

  // set only the date
  void _setDeadlineTime(TimeOfDay datetime) {
    currentDeadline = DateTime(currentDeadline.year, currentDeadline.month,
        currentDeadline.day, datetime.hour, datetime.minute);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: currentDeadline,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(DateTime.now().year - 50),
        lastDate: DateTime(DateTime.now().year + 50));
    if (picked != null) {
      setState(() {
        _setDeadlineDate(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _getDeadlineTime(),
    );
    if (picked != null) {
      setState(() {
        _setDeadlineTime(picked);
      });
    }
  }
}
