import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_refactor/backend/auth.dart';
import 'package:todo_refactor/firebase_options.dart';
import 'package:todo_refactor/provider/auth_provider.dart';
import 'package:todo_refactor/views/authentication/auth_view.dart';
import 'package:todo_refactor/views/authentication/login_view.dart';
import 'package:todo_refactor/views/home/home_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: ((context) => AuthProvider()))
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: WidgetTree());
  }
}

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: AuthAPI().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomeView();
          } else {
            return const AuthView();
          }
        });
  }
}
