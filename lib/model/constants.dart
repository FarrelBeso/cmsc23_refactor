import 'package:flutter/material.dart';
import 'package:todo_refactor/views/home/personal_profile_view.dart';
import 'package:todo_refactor/views/home/task_add.dart';
import 'package:todo_refactor/views/home/tasks_all_view.dart';

enum TaskStatus {
  notStarted('Not Started', Colors.black45),
  working('Working', Colors.yellow),
  done('Done', Colors.green);

  const TaskStatus(this.label, this.color);
  final String label;
  final Color color;
}

enum MainPageViews {
  taskAll('Task All', TasksView()),
  personalProfile('Personal Profile', PersonalProfileView()),
  taskAdd('Task Add', TaskAddView());

  const MainPageViews(this.label, this.view);
  final String label;
  final Widget view;
}
