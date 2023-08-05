import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_refactor/provider/homepage_provider.dart';
import 'package:todo_refactor/provider/task_provider.dart';
import 'package:todo_refactor/provider/user_provider.dart';
import 'package:todo_refactor/views/home/home_view.dart';

class HomeRoot extends StatelessWidget {
  const HomeRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: ((context) => HomepageProvider())),
      ChangeNotifierProvider(create: ((context) => TaskProvider())),
      ChangeNotifierProvider(create: ((context) => UserProvider())),
    ], child: const HomeView());
  }
}
