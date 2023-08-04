import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_refactor/model/constants.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/task_model.dart';
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
  TaskStatus currentStatus = TaskStatus.notStarted;
  DateTime currentDeadline = DateTime.now();
  TextEditingController descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // build the dropdown items here
    final List<DropdownMenuItem<TaskStatus>> taskStatusEntries =
        <DropdownMenuItem<TaskStatus>>[];
    for (final TaskStatus status in TaskStatus.values) {
      taskStatusEntries.add(DropdownMenuItem<TaskStatus>(
        value: status,
        child: Container(
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.all(5),
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: status.color, shape: BoxShape.circle),
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
                  TextFormField(
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
                  ),
                  // TextFormField(
                  //   decoration: InputDecoration(labelText: 'Username'),
                  //   style: TextStyle(fontSize: 16, color: Colors.white70),
                  // ),
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
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24)),
                                child: DropdownButton(
                                    value: currentStatus,
                                    items: taskStatusEntries,
                                    underline: Container(),
                                    onChanged: (value) {
                                      setState(() {
                                        currentStatus = value!;
                                      });
                                    }),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  _dateTimeSelectWrapper(context);
                                },
                                child: Text(
                                  _dateTimeFormat(),
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ButtonStyle(
                                    side: MaterialStatePropertyAll(
                                        BorderSide(color: Colors.white60))),
                              )

                              // Text(
                              //   'Working',
                              //   style: TextStyle(color: Colors.white),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            // Container(
            //   padding: EdgeInsets.only(top: 16, bottom: 4, left: 16, right: 16),
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: Align(
            //           alignment: Alignment.centerLeft,
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Text(
            //                 'Last modified by',
            //                 style:
            //                     TextStyle(fontSize: 10, color: Colors.black45),
            //               ),
            //               Text(
            //                 'Lorem Ipsum, Jan 14, 4:20 PM',
            //                 style:
            //                     TextStyle(fontSize: 12, color: Colors.black87),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //       IconButton.filledTonal(
            //           onPressed: () {}, icon: Icon(Icons.edit))
            //     ],
            //   ),
            // ),

            Divider(),
            Container(
              padding: EdgeInsets.all(16),
              child: TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                    hintText: 'Task Description (optional)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8))),
                style: TextStyle(color: Colors.black45, fontSize: 14),
                keyboardType: TextInputType.multiline,
                maxLines: 16,
              ),
            ),
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
                          _addTaskWrapper(context);
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

  // useful functions

  // wrapper for adding the tasks
  Future<void> _addTaskWrapper(BuildContext context) async {
    // first set the task model
    TaskModel task = _setNewTask(context);
    // then check for the response
    ResponseModel response =
        await Provider.of<TaskProvider>(context).addTask(task);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response.message!)));
      // clear the inputs if successful
      if (response.success) _resetTextFields();
    }
  }

  void _resetTextFields() {
    nameController.clear();
    descriptionController.clear();
  }

  // transform the input
  TaskModel _setNewTask(BuildContext context) {
    // set the task
    String id = Uuid().v4();
    TaskModel task = TaskModel(
      id: id,
      taskName: nameController.text,
      status: currentStatus.label,
      deadline: currentDeadline,
      description: descriptionController.text,
      // misc info
      ownerId:
          Provider.of<AuthProvider>(context, listen: false).currentuser!.id,
      lastEditedDate: DateTime.now(),
      lastEditUserId:
          Provider.of<AuthProvider>(context, listen: false).currentuser!.id,
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
