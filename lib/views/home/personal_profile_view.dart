import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_refactor/provider/auth_provider.dart';

class PersonalProfileView extends StatelessWidget {
  const PersonalProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, provider, child) {
      return Expanded(
        child: Container(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                color: Theme.of(context).primaryColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 24,
                    ),
                    Text(
                      '${provider.currentuser?.firstName} ${provider.currentuser?.lastName}',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Text(
                      provider.currentuser?.username ?? 'N/A',
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
              ),

              // put whatever the current tab is
              ProfileSection()
              //FriendsSection()
            ],
          ),
        ),
      );
    });
  }
}

// the profile and friends views
class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                child: Row(
                  children: [
                    Container(padding: EdgeInsets.all(8), child: Text('ID: ')),
                    Text(provider.currentuser?.id ?? 'N/A')
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
                      Text(DateFormat(DateFormat.YEAR_MONTH_DAY).format(
                          provider.currentuser?.birthday ?? DateTime(1900)))
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
                      Text(provider.currentuser?.location ?? 'N/A')
                    ],
                  ),
                ),
              ),
              Divider(),
              Container(
                  padding: EdgeInsets.all(8),
                  alignment: Alignment.topLeft,
                  child: Text('Sample Biography. Lorem Ipsum dolor sit amet.'))
            ],
          ),
        );
      },
    );
  }
}

// insert mock data
class FriendsSection extends StatelessWidget {
  const FriendsSection({super.key});

  @override
  Widget build(BuildContext context) {
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
