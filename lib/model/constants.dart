import 'package:flutter/material.dart';
import 'package:todo_refactor/views/home/personal_profile_view.dart';
import 'package:todo_refactor/views/home/task_add.dart';
import 'package:todo_refactor/views/home/tasks_all_view.dart';

enum TaskStatus {
  notStarted('Not Started', Colors.black12, true),
  working('Working', Colors.yellow, true),
  done('Done', Colors.green, true),
  neglected('Neglected', Colors.black54, false),
  late('Late', Colors.red, false),
  doneLate('Done Late', Colors.orange, false);

  const TaskStatus(this.label, this.color, this.selectable);
  final String label;
  final Color color;
  final bool selectable;

  // fetching the color from name
  Color fetchColorFromName(String name) {
    switch (name) {
      case 'Not Started':
        return TaskStatus.notStarted.color;
      case 'Working':
        return TaskStatus.working.color;
      case 'Done':
        return TaskStatus.done.color;
      case 'Neglected':
        return TaskStatus.neglected.color;
      case 'Late':
        return TaskStatus.late.color;
      case 'Done Late':
        return TaskStatus.doneLate.color;
      default:
        return TaskStatus.notStarted.color;
    }
  }
}

enum MainPageViews {
  taskAll('Task All', TasksView()),
  personalProfile('Personal Profile', PersonalProfileView()),
  taskAdd('Task Add', TaskAddView());

  const MainPageViews(this.label, this.view);
  final String label;
  final Widget view;
}
