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
                                _selectTime(context);
                                _selectDate(context);
                              },
                              child: Text(
                                'SAMPLE TIME',
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
              cursorColor: Colors.white,
              decoration: InputDecoration(
                  hintText: 'Task Description',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8))),
              style: TextStyle(color: Colors.black45, fontSize: 14),
              keyboardType: TextInputType.multiline,
              maxLines: 10,
            ),
          ),
        ],
      ),
    ));
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
