import 'package:flutter/material.dart';

class TaskAddView extends StatefulWidget {
  const TaskAddView({super.key});

  @override
  State<TaskAddView> createState() => _TaskAddViewState();
}

class _TaskAddViewState extends State<TaskAddView> {
  TaskStatus currentStatus = TaskStatus.notStarted;

  @override
  Widget build(BuildContext context) {
    // build the dropdown items here
    final List<DropdownMenuEntry<TaskStatus>> taskStatusEntries =
        <DropdownMenuEntry<TaskStatus>>[];
    for (final TaskStatus status in TaskStatus.values) {
      taskStatusEntries.add(
          DropdownMenuEntry<TaskStatus>(value: status, label: status.label));
    }

    return Expanded(
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
                    decoration: InputDecoration(labelText: 'Task Name'),
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
                  Divider(),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.all(5),
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                    color: currentStatus.color,
                                    shape: BoxShape.circle),
                              ),
                              DropdownMenu<TaskStatus>(
                                initialSelection: TaskStatus.notStarted,
                                dropdownMenuEntries: taskStatusEntries,
                                onSelected: (value) {
                                  setState(() {
                                    currentStatus =
                                        value ?? TaskStatus.notStarted;
                                  });
                                },
                              ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 8),
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Description'),
                      style: TextStyle(color: Colors.black45, fontSize: 14),
                    ),
                  ),
                  TextFormField(
                      decoration: InputDecoration(
                          labelText:
                              'Do the homework and the tasks at pages 5, 6, and 7.'))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // useful functions
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year + 50));
    if (picked != null)
      setState(() {
        print(picked);
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null)
      setState(() {
        print(picked);
      });
  }
}

enum TaskStatus {
  notStarted('Not Started', Colors.black45),
  working('Working', Colors.yellow),
  done('Done', Colors.green),
  late('Late', Colors.red),
  doneLate('Done Late', Colors.orange);

  const TaskStatus(this.label, this.color);
  final String label;
  final Color color;
}
