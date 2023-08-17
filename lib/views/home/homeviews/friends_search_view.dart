import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_refactor/model/constants.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/user_model.dart';
import 'package:todo_refactor/provider/auth_provider.dart';
import 'package:todo_refactor/provider/user_provider.dart';
import 'package:todo_refactor/utilities/user_utils.dart';

class FriendsView extends StatefulWidget {
  const FriendsView({super.key});

  @override
  State<FriendsView> createState() => _FriendsViewState();
}

class _FriendsViewState extends State<FriendsView> {
  // the search query
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [_searchBar()],
            ),
          ),
          Divider(),
          _futureBuilderWrapper()
        ],
      ),
    );
  }

  // the main search bar
  Widget _searchBar() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.all(8),
        child: SearchBar(
          trailing: [
            Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.search))
          ],
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
        ),
      ),
    );
  }

  // future builder wrapper
  Widget _futureBuilderWrapper() {
    return FutureBuilder(
        future: _getUserListWrapper(),
        builder: ((context, snapshot) {
          Widget content;
          // what would be on it?
          if (snapshot.hasData) {
            if ((snapshot.data as List).isNotEmpty) {
              content = _userListWidget(snapshot.data!);
            } else {
              content = _emptyListWidget();
            }
            // assign the data here
          } else if (snapshot.hasError) {
            content = _errorWidget();
          } else {
            content = _loadingWidget();
          }
          return Expanded(child: content);
        }));
  }

  // the info list
  Widget _userListWidget(List<UserModel> userlist) {
    return ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: userlist.length,
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemBuilder: (BuildContext context, int index) {
          UserModel user = userlist[index];
          return InkWell(
            onTap: () {
              // switch to user view
              // _viewTaskWrapper(user);
            },
            child: Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.firstName} ${user.lastName}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        user.username!,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  )),
                  // replace if friend or not
                  // Container(
                  //   child: Row(
                  //     children: [
                  //       Container(
                  //         margin: EdgeInsets.all(5),
                  //         width: 10.0,
                  //         height: 10.0,
                  //         decoration: BoxDecoration(
                  //             color: status.color, shape: BoxShape.circle),
                  //       ),
                  //       Text(status.label),
                  //     ],
                  //   ),
                  // ),
                  Container(child: _personStatusButton(user.id!))
                ],
              ),
            ),
          );
        });
  }

  // button builder depending on friend status
  Widget _personStatusButton(String otherId) {
    UserModel currentUser =
        Provider.of<AuthProvider>(context, listen: false).user!;
    UserRelationStatus status = UserUtils().getStatus(currentUser, otherId);
    switch (status) {
      case UserRelationStatus.stranger:
        return FilledButton(onPressed: () {}, child: Text('Add Friend'));
      case UserRelationStatus.request:
        return FilledButton.tonal(
            onPressed: () {}, child: Text('Accept Request'));
      case UserRelationStatus.pending:
        return FilledButton.tonal(
            onPressed: () {}, child: Text('Cancel Request'));
      case UserRelationStatus.friend:
        return OutlinedButton(onPressed: () {}, child: Text('Unfriend'));
    }
  }

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

  Widget _emptyListWidget() {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 24,
          ),
          Text(
            'No users found',
            style: TextStyle(fontSize: 20),
          )
        ],
      ),
    );
  }

  // wrapper for calling the async user list
  Future<List<UserModel>?> _getUserListWrapper() async {
    ResponseModel res = await Provider.of<UserProvider>(context, listen: false)
        .searchUsers(searchQuery);
    if (context.mounted) {
      if (res.success) {
        // remove the user itself
        List<UserModel> userlist = res.content;
        final currentuser =
            Provider.of<AuthProvider>(context, listen: false).user!;
        userlist =
            userlist.where((user) => (user.id != currentuser.id)).toList();
        return userlist;
      } else {
        // ScaffoldMessenger.of(context)
        //     .showSnackBar(SnackBar(content: Text(res.message!)));
      }
    }
    return [];
  }
}
