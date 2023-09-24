import 'package:flutter/material.dart';
import 'package:todo_refactor/views/home/homeviews/friends_search_view.dart';
import 'package:todo_refactor/views/home/homeviews/localmail_view.dart';
import 'package:todo_refactor/views/home/homeviews/personal_profile_view.dart';
import 'package:todo_refactor/views/home/homeviews/task_add_view.dart';
import 'package:todo_refactor/views/home/homeviews/task_edit_view.dart';
import 'package:todo_refactor/views/home/homeviews/task_info_view.dart';
import 'package:todo_refactor/views/home/homeviews/tasks_all_view.dart';

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

  // fetching the task status
  factory TaskStatus.fetchFromName(String name) {
    switch (name) {
      case 'Not Started':
        return TaskStatus.notStarted;
      case 'Working':
        return TaskStatus.working;
      case 'Done':
        return TaskStatus.done;
      case 'Neglected':
        return TaskStatus.neglected;
      case 'Late':
        return TaskStatus.late;
      case 'Done Late':
        return TaskStatus.doneLate;
      default:
        return TaskStatus.notStarted;
    }
  }
}

enum MainPageViews {
  personalProfile('Personal Profile', PersonalProfileView()),
  friendAll('Friend All', FriendsView()),
  localMail('Local Mail', LocalMailView()),
  taskAll('Task All', TasksView()),
  taskAdd('Task Add', TaskAddView()),
  taskInfo('Task Info', TaskInfoView()),
  taskEdit('Task Edit', TaskEditView());

  const MainPageViews(this.label, this.view);
  final String label;
  final Widget view;
}

enum UserRelationStatus {
  stranger,
  request,
  pending,
  friend
  // request = the current user received friend request from other user
  // pending = the current user sent a friend request to other user
}
