import 'package:flutter/material.dart';
import 'package:todo_refactor/views/authentication/login_view.dart';
import 'package:todo_refactor/views/home/personal_profile_view.dart';
import 'package:todo_refactor/views/home/tasks_all_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 2;
  Widget _displayWidget = TasksView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Row(
        children: [
          NavigationRail(
            leading: Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.menu,
                    ))),
            onDestinationSelected: (index) {
              if (index == 4) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const LoginView()));
              }
            },
            destinations: [
              NavigationRailDestination(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  icon: Icon(Icons.person),
                  label: Text(
                    'Profile',
                  )),
              NavigationRailDestination(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  icon: Icon(Icons.group),
                  label: Text('Users')),
              NavigationRailDestination(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  icon: Icon(Icons.home),
                  label: Text('Tasks')),
              NavigationRailDestination(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  icon: Icon(Icons.mail),
                  label: Text('Notifs')),
              NavigationRailDestination(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  icon: Icon(Icons.exit_to_app),
                  label: Text('Logout')),
            ],
            selectedIndex: _selectedIndex,
            groupAlignment: 0.0,
            backgroundColor: Theme.of(context).primaryColorLight,
          ),
          _displayWidget
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }

  // which to display?
  Widget displayMain(int index) {
    switch (index) {
      case 0:
        return PersonalProfileView();
      case 2:
        return TasksView();
      default:
        return Placeholder();
    }
  }
}
