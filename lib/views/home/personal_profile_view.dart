import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/user_model.dart';
import 'package:todo_refactor/utilities/auth_utils.dart';

class PersonalProfileView extends StatelessWidget {
  const PersonalProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: FutureBuilder(
            future: AuthUtils().fetchCurrentUser(),
            builder: (context, snapshot) {
              Widget displayWidget;
              if (snapshot.hasData) {
                ResponseModel res = snapshot.data!;
                // check if successful
                if (res.success) {
                  displayWidget = _contentWrapper(context, res.content);
                } else {
                  displayWidget = _errorWidget();
                }
              } else if (snapshot.hasError) {
                displayWidget = _errorWidget();
              } else {
                displayWidget = _loadingWidget();
              }
              return displayWidget;
            }));
  }

  // widgets

  // content wrapper
  Widget _contentWrapper(BuildContext context, UserModel usermodel) {
    return Container(
      child: Column(
        children: [
          // put whatever the current tab is
          _profileHeader(context, usermodel),
          _profileSection(usermodel),
          //FriendsSection()
        ],
      ),
    );
  }

  Widget _profileHeader(BuildContext context, UserModel usermodel) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      color: Theme.of(context).primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 24,
          ),
          Text(
            '${usermodel.firstName} ${usermodel.lastName}',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            usermodel.username ?? 'N/A',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'PROFILE',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Text('FRIENDS',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileSection(UserModel usermodel) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            child: Row(
              children: [
                Container(padding: EdgeInsets.all(8), child: Text('ID: ')),
                Text(usermodel.id ?? 'N/A')
              ],
            ),
          ),
          Card(
            child: Container(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                      padding: EdgeInsets.all(8), child: Icon(Icons.cake)),
                  Text(DateFormat(DateFormat.YEAR_MONTH_DAY)
                      .format(usermodel.birthday ?? DateTime(1900)))
                ],
              ),
            ),
          ),
          Card(
            child: Container(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.location_on)),
                  Text(usermodel.location ?? 'N/A')
                ],
              ),
            ),
          ),
          Divider(),
          Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.topLeft,
              child: Text(usermodel.biography ?? 'No biography available.'))
        ],
      ),
    );
  }

  // misc widgets
  Widget _errorWidget() {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 24,
          ),
          Text(
            'Failed to fetch data',
            style: TextStyle(fontSize: 20),
          )
        ],
      ),
    );
  }

  Widget _loadingWidget() {
    return Center(
      child: SizedBox(
        width: 60,
        height: 60,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _friendSection(UserModel usermodel) {
    return Container(
      padding: EdgeInsets.all(8),
      child: ListView.builder(
          itemCount: 15,
          itemBuilder: ((context, index) {
            // the buttons depend on friend status
            return Card(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'First Last',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      'UsernameXXXX',
                      style: TextStyle(fontSize: 12),
                    )
                  ],
                ),
              ),
            );
          })),
    );
  }
}
