import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_refactor/provider/homepage_provider.dart';
import 'package:todo_refactor/views/home/home_view.dart';

class HomeRoot extends StatelessWidget {
  const HomeRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: ((context) => HomepageProvider())),
    ], child: const HomeView());
  }
}
