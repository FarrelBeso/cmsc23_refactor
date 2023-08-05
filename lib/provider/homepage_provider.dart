import 'package:flutter/material.dart';
import 'package:todo_refactor/model/constants.dart';

class HomepageProvider extends ChangeNotifier {
  // which widget to display?
  MainPageViews currentView = MainPageViews.taskAll;
  // potential arguments to be passed
  dynamic arguments;

  // switch view
  void setView(MainPageViews view) {
    currentView = view;
    notifyListeners();
  }

  // set argument
  void setArgument(dynamic arg) {
    arguments = arg;
    notifyListeners();
  }
}
