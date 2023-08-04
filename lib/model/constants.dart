import 'package:flutter/material.dart';

enum TaskStatus {
  notStarted('Not Started', Colors.black45),
  working('Working', Colors.yellow),
  done('Done', Colors.green);

  const TaskStatus(this.label, this.color);
  final String label;
  final Color color;
}
