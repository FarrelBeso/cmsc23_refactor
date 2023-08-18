import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_refactor/model/user_model.dart';
import 'package:todo_refactor/provider/auth_provider.dart';

class PersonalProfileView extends StatefulWidget {
  const PersonalProfileView({super.key});

  @override
  State<PersonalProfileView> createState() => _PersonalProfileViewState();
}

class _PersonalProfileViewState extends State<PersonalProfileView> {
  late UserModel user;
  @override
  Widget build(BuildContext context) {
    // fetch the user first
    user = Provider.of<AuthProvider>(context, listen: false).user!;
    return Expanded(child: _contentWrapper());
  }

  // widgets
  Widget _contentWrapper() {
    return Column(
      children: [
        // put whatever the current tab is
        _profileHeader(),
        _profileSection(),
        //FriendsSection()
      ],
    );
  }

  Widget _profileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Theme.of(context).primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 24,
          ),
          Text(
            '${user.firstName} ${user.lastName}',
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            user.username!,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text(
                    'PROFILE',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text('FRIENDS',
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

  Widget _profileSection() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                Container(
                    padding: const EdgeInsets.all(8),
                    child: const Text('ID: ')),
                Text(user.id!)
              ],
            ),
          ),
          Card(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.cake)),
                  Text(DateFormat(DateFormat.YEAR_MONTH_DAY)
                      .format(user.birthday!))
                ],
              ),
            ),
          ),
          Card(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.location_on)),
                  Text(user.location!)
                ],
              ),
            ),
          ),
          const Divider(),
          Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.topLeft,
              child: Text(user.biography!))
        ],
      ),
    );
  }

  // misc widgets
  Widget _errorWidget() {
    return const Center(
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
    return const Center(
      child: SizedBox(
        width: 60,
        height: 60,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _friendSection(UserModel usermodel) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: ListView.builder(
          itemCount: 15,
          itemBuilder: ((context, index) {
            // the buttons depend on friend status
            return Card(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: const Column(
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
