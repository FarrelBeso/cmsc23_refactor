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
  // view all users
  List<UserModel>? currentLoadResult;
  // the current user
  late UserModel currentUser;

  @override
  Widget build(BuildContext context) {
    currentUser = Provider.of<AuthProvider>(context, listen: false).user!;
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
          _contentWrapper()
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

  // wrapper on the overall content
  Widget _contentWrapper() {
    if (currentLoadResult == null) {
      return _futureBuilderWrapper();
    } else {
      // filter the userlist here
      List<UserModel> userlist = _searchFilter();
      return _userListWidget(userlist);
    }
  }

  // the filter function based on the
  // current load result
  List<UserModel> _searchFilter() {
    // manual filtering

    if (searchQuery.isEmpty) {
      return currentLoadResult!;
    } else {
      List<UserModel> list = [];
      String lowersearch = searchQuery.toLowerCase();
      for (var user in currentLoadResult!) {
        if (!(list.contains(user)) &&
            ((user.firstName!.toLowerCase()).contains(lowersearch) ||
                (user.lastName!.toLowerCase()).contains(lowersearch) ||
                (user.username!.toLowerCase()).contains(lowersearch))) {
          list.add(user);
        }
      }
      return list;
    }
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
    return Expanded(
      child: ListView.separated(
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
                    Container(child: _personStatusButton(user.id!))
                  ],
                ),
              ),
            );
          }),
    );
  }

  // button builder depending on friend status
  Widget _personStatusButton(String otherId) {
    UserRelationStatus status = UserUtils().getStatus(currentUser, otherId);
    switch (status) {
      case UserRelationStatus.stranger:
        return FilledButton(
            onPressed: () {
              _statusButtonAction(otherId, 'addFriend');
            },
            child: Text('Add Friend'));
      case UserRelationStatus.request:
        return Container(
          child: Row(
            children: [
              FilledButton.tonal(
                  onPressed: () {
                    _statusButtonAction(otherId, 'acceptRequest');
                  },
                  child: Text('Accept')),
              SizedBox(
                width: 4,
              ),
              OutlinedButton(
                  onPressed: () {
                    _statusButtonAction(otherId, 'rejectRequest');
                  },
                  child: Text('Reject'))
            ],
          ),
        );

      case UserRelationStatus.pending:
        return FilledButton.tonal(
            onPressed: () {
              _statusButtonAction(otherId, 'cancelRequest');
            },
            child: Text('Cancel Request'));
      case UserRelationStatus.friend:
        return OutlinedButton(
            onPressed: () {
              _statusButtonAction(otherId, 'removeFriend');
            },
            child: Text('Unfriend'));
    }
  }

  // actions on the button
  Future<void> _statusButtonAction(String otherId, String action) async {
    switch (action) {
      case 'addFriend':
        await Provider.of<UserProvider>(context, listen: false)
            .addFriend(otherId);
      case 'acceptRequest':
        await Provider.of<UserProvider>(context, listen: false)
            .acceptRequest(otherId);
      case 'rejectRequest':
        await Provider.of<UserProvider>(context, listen: false)
            .rejectRequest(otherId);
      case 'cancelRequest':
        await Provider.of<UserProvider>(context, listen: false)
            .cancelRequest(otherId);
      case 'removeFriend':
        await Provider.of<UserProvider>(context, listen: false)
            .removeFriend(otherId);
    }

    // the state would also change
    setState(() {
      switch (action) {
        case 'addFriend':
          currentUser.pendingRequests!.add(otherId);
        case 'acceptRequest':
          currentUser.friendRequests!.remove(otherId);
          currentUser.friendIds!.add(otherId);
        case 'rejectRequest':
          currentUser.friendRequests!.remove(otherId);
        case 'cancelRequest':
          currentUser.pendingRequests!.remove(otherId);
        case 'removeFriend':
          currentUser.friendIds!.remove(otherId);
      }
    });
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
    // only reload if the current is null
    List<UserModel>? userlist =
        Provider.of<UserProvider>(context, listen: false).userlist;
    if (userlist == null) {
      ResponseModel res =
          await Provider.of<UserProvider>(context, listen: false)
              .updateUserList(searchQuery);
      if (context.mounted) {
        if (res.success) {
          // reupdate the tasklist
          userlist = Provider.of<UserProvider>(context, listen: false).userlist;
          // also update the state
          setState(() {
            currentLoadResult = userlist;
          });
        } else {
          // ScaffoldMessenger.of(context)
          //     .showSnackBar(SnackBar(content: Text(res.message!)));
        }
      }
    }
    return userlist;
  }
}
