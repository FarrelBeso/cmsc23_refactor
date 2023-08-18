import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_refactor/model/constants.dart';
import 'package:todo_refactor/provider/homepage_provider.dart';
import 'package:todo_refactor/utilities/auth_utils.dart';

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
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.menu,
                      ))),
              onDestinationSelected: (index) async {
                if (index == 4) {
                  await AuthUtils().signOut();
                  // put the message in a snackbar
                  if (context.mounted) {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //     SnackBar(content: Text(response.message!)));
                  }
                }

                // default = changing panels
                setState(() {
                  _selectedIndex = index;
                  _updateDisplayByIndex(index, context);
                });
              },
              destinations: const [
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
        floatingActionButton: _floatingButtonBuilder());
  }

  // which to display, and update the provider
  void _updateDisplayByIndex(int index, BuildContext context) {
    MainPageViews view;
    switch (index) {
      case 0:
        view = MainPageViews.personalProfile;
      case 1:
        view = MainPageViews.friendAll;
      case 2:
        view = MainPageViews.taskAll;
      default:
        view = MainPageViews.taskAll;
        print('Unknown view');
    }
    // update the provider
    Provider.of<HomepageProvider>(context, listen: false).setView(view);
  }

  // the floating button depends on the state
  Widget _floatingButtonBuilder() {
    // is the button visible
    return Visibility(
        visible: Provider.of<HomepageProvider>(context).currentView ==
            MainPageViews.taskAll,
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              Provider.of<HomepageProvider>(context, listen: false)
                  .setView(MainPageViews.taskAdd);
            });
          },
          child: const Icon(Icons.add),
        ));
  }
}
