import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_refactor/model/localmail_model.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/user_model.dart';
import 'package:todo_refactor/provider/auth_provider.dart';
import 'package:todo_refactor/provider/localmail_provider.dart';
import 'package:todo_refactor/utilities/localmail_utils.dart';

class LocalMailView extends StatefulWidget {
  const LocalMailView({super.key});

  @override
  State<LocalMailView> createState() => _LocalMailViewState();
}

class _LocalMailViewState extends State<LocalMailView> {
  List<LocalMailModel>? currentLoadResult;
  late UserModel currentUser;

  @override
  Widget build(BuildContext context) {
    currentUser = Provider.of<AuthProvider>(context, listen: false).user!;
    return Expanded(child: _contentWrapper());
  }

  // wrapper on the overall content
  Widget _contentWrapper() {
    if (currentLoadResult == null) {
      return _futureBuilderWrapper();
    } else {
      return _mailListWidget();
    }
  }

  // future builder wrapper
  Widget _futureBuilderWrapper() {
    return FutureBuilder(
        future: _getMailListWrapper(),
        builder: ((context, snapshot) {
          Widget content;
          // what would be on it?
          if (snapshot.hasData) {
            if ((snapshot.data as List).isNotEmpty) {
              content = _mailListWidget();
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
  Widget _mailListWidget() {
    return Expanded(
      child: ListView.separated(
          padding: EdgeInsets.all(16),
          itemCount: currentLoadResult!.length,
          separatorBuilder: (context, index) {
            return Divider();
          },
          itemBuilder: (BuildContext context, int index) {
            LocalMailModel mail = currentLoadResult![index];
            return _mailBuilder(mail);
          }),
    );
  }

  // builder for the mail
  Widget _mailBuilder(LocalMailModel mail) {
    // choose icon

    return ListTile(
      leading: LocalMailUtils().mailIcon(mail),
      title: Text(mail.message!),
      subtitle: Text(mail.timestamp.toString()),
    );
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
            'No notifications found',
            style: TextStyle(fontSize: 20),
          )
        ],
      ),
    );
  }

  // wrapper for calling the async mail list
  Future<List<LocalMailModel>?> _getMailListWrapper() async {
    // only reload if the current is null
    List<LocalMailModel>? maillist =
        Provider.of<LocalMailProvider>(context, listen: false).mailFeed;
    if (maillist == null) {
      ResponseModel res =
          await Provider.of<LocalMailProvider>(context, listen: false)
              .updateFeed();
      if (context.mounted) {
        if (res.success) {
          // reupdate the tasklist
          maillist =
              Provider.of<LocalMailProvider>(context, listen: false).mailFeed;
          // also update the state
          setState(() {
            currentLoadResult = maillist;
          });
        } else {
          // ScaffoldMessenger.of(context)
          //     .showSnackBar(SnackBar(content: Text(res.message!)));
        }
      }
    }
    return maillist;
  }
}
