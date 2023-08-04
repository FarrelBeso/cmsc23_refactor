import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskAddView extends StatefulWidget {
  const TaskAddView({super.key});

  @override
  State<TaskAddView> createState() => _TaskAddViewState();
}

class _TaskAddViewState extends State<TaskAddView> {
  TextEditingController nameController = TextEditingController();
  TaskStatus currentStatus = TaskStatus.notStarted;
  DateTime dateDeadline = DateTime.now();
  TimeOfDay timeDeadline = TimeOfDay.now();
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
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                        labelText: 'Task Name',
                        labelStyle: TextStyle(color: Colors.white60)),
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  // TextFormField(
                  //   decoration: InputDecoration(labelText: 'Username'),
                  //   style: TextStyle(fontSize: 16, color: Colors.white70),
                  // ),
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
                cursorColor: Colors.white,
                decoration: InputDecoration(
                    hintText: 'Task Description (optional)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8))),
                style: TextStyle(color: Colors.black45, fontSize: 14),
                keyboardType: TextInputType.multiline,
                maxLines: 16,
              ),
            ),
          ],
        ),
      )),
    );
  }

  // useful functions

  Future<void> _dateTimeSelectWrapper(BuildContext context) async {
    await _selectDate(context);
    if (context.mounted) await _selectTime(context);
  }

  // based on the date and time deadline
  String _dateTimeFormat() {
    // String to be appended
    final now = DateTime.now();
    String dateString = DateFormat.yMMMd().format(dateDeadline);
    String timeString = DateFormat.jm().format(DateTime(
        now.year, now.month, now.day, dateDeadline.hour, dateDeadline.minute));

    return '$dateString, $timeString';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: dateDeadline,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year + 50));
    if (picked != null) {
      setState(() {
        dateDeadline = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: timeDeadline,
    );
    if (picked != null) {
      setState(() {
        timeDeadline = picked;
      });
    }
  }
}

enum TaskStatus {
  notStarted('Not Started', Colors.black45),
  working('Working', Colors.yellow),
  done('Done', Colors.green);

  const TaskStatus(this.label, this.color);
  final String label;
  final Color color;
}
