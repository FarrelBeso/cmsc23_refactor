import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_refactor/model/constants.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/user_model.dart';
import 'package:todo_refactor/provider/auth_provider.dart';
import 'package:todo_refactor/provider/homepage_provider.dart';
import 'package:todo_refactor/views/authentication/login_view.dart';
import 'package:todo_refactor/views/home/personal_profile_view.dart';
import 'package:todo_refactor/views/home/task_add.dart';
import 'package:todo_refactor/views/home/tasks_all_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 2;

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
            onDestinationSelected: (index) async {
              if (index == 4) {
                ResponseModel response =
                    await Provider.of<AuthProvider>(context, listen: false)
                        .signOutWrapper();
                // put the message in a snackbar
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(response.message!)));
                }
              }

              // default = changing panels
              setState(() {
                _selectedIndex = index;
                _updateDisplayByIndex(index, context);
              });
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
          Consumer<HomepageProvider>(builder: (context, provider, child) {
            return Container(child: provider.currentView.view);
          })
        ],
      )),
      // this button is only visible on task all
      floatingActionButton: Visibility(
        visible: Provider.of<HomepageProvider>(context).currentView ==
            MainPageViews.taskAll,
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              Provider.of<HomepageProvider>(context, listen: false)
                  .setView(MainPageViews.taskAdd);
            });
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  // which to display, and update the provider
  void _updateDisplayByIndex(int index, BuildContext context) {
    MainPageViews view;
    switch (index) {
      case 0:
        view = MainPageViews.personalProfile;
      case 2:
        view = MainPageViews.taskAll;
      default:
        view = MainPageViews.taskAll;
        print('Unknown view');
    }
    // update the provider
    Provider.of<HomepageProvider>(context, listen: false).setView(view);
  }
}
