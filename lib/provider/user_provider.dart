import 'package:flutter/foundation.dart';
import 'package:todo_refactor/backend/auth_api.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/user_model.dart';
import 'package:todo_refactor/utilities/user_utils.dart';

class UserProvider extends ChangeNotifier {
  List<UserModel>? currentUserList;

  List<UserModel>? get userlist => currentUserList;

  void setResultList(List<UserModel> userlist) {
    currentUserList = userlist;
    notifyListeners();
  }

  void clearResultList() {
    currentUserList = null;
    notifyListeners();
  }

  // update the user list
  Future<ResponseModel> updateUserList(String stringQuery) async {
    ResponseModel res = await UserUtils().getUsersByQuery(stringQuery);
    if (res.success) {
      // except the main user
      List<UserModel> list = (res.content)
          .where((user) => (user.id != AuthAPI().currentUser!.uid))
          .toList();
      setResultList(list);
    }
    return res;
  }
}
