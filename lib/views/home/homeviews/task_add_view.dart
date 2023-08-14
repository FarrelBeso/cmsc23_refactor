import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_refactor/model/constants.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/task_model.dart';
import 'package:todo_refactor/model/user_model.dart';
import 'package:todo_refactor/provider/auth_provider.dart';
import 'package:todo_refactor/provider/homepage_provider.dart';
import 'package:todo_refactor/provider/task_provider.dart';
import 'package:uuid/uuid.dart';

class TaskAddView extends StatefulWidget {
  const TaskAddView({super.key});

  @override
  State<TaskAddView> createState() => _TaskAddViewState();
}

class _TaskAddViewState extends State<TaskAddView> {
  TextEditingController nameController = TextEditingController();
  late TaskStatus currentStatus; // to be set at the first item
  DateTime currentDeadline = DateTime.now();
  TextEditingController descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final List<DropdownMenuItem<TaskStatus>> taskStatusEntries =
      <DropdownMenuItem<TaskStatus>>[];

  // call this if variables haven't been initialized properly
  bool hasInit = false;

  @override
  Widget build(BuildContext context) {
// initialize here
    _initWrapper();

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

  // initialize
  void _initWrapper() {
    // only runs if it has not yet init
    if (!hasInit) {
      _setStatusList();
      _valuesInit();
      hasInit = true;
    }
  }

  // value initialization
  void _valuesInit() {
    currentStatus = taskStatusEntries.first.value!;
  }

  // set the status choice list
  void _setStatusList() {
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
    TaskModel task = _setNewTask();

    ResponseModel res = await Provider.of<TaskProvider>(context).addTask(task);
    if (context.mounted) {
      if (res.success) {
        _resetTextFields();
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res.message!)));
    }
  }

  void _resetTextFields() {
    nameController.clear();
    descriptionController.clear();
  }

  // transform the input
  TaskModel _setNewTask() {
    UserModel user = Provider.of<AuthProvider>(context).user!;
    TaskModel task = TaskModel(
      id: Uuid().v4(),
      taskName: nameController.text,
      status: currentStatus.label,
      deadline: currentDeadline,
      description: descriptionController.text,
      // misc info
      ownerId: user.id,
      lastEditedDate: DateTime.now(),
      lastEditUserId: user.id,
      // more info
      ownerFullName: '${user.firstName} ${user.lastName}',
      lastEditFullName: '${user.firstName} ${user.lastName}',
    );

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
