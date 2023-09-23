import 'package:flutter/foundation.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/user_model.dart';
import 'package:todo_refactor/utilities/auth_utils.dart';

/*
Essentially, providers exist to reduce fetching content
from databases
*/
class AuthProvider extends ChangeNotifier {
  UserModel? currentUser;

  UserModel? get user => currentUser;

  // set the current user
  void setCurrentUser(UserModel user) {
    currentUser = user;
    notifyListeners();
  }

  // remove the current user
  void removeCurrentUser() {
    currentUser = null;
    notifyListeners();
  }

  // wrappers
  Future<ResponseModel> signIn(UserModel user, String password) async {
    ResponseModel res = await AuthUtils().signIn(user, password);
    // the additional part
    if (res.success) {
      setCurrentUser(user);
    }
    return res;
  }

  Future<ResponseModel> login(String email, String password) async {
    try {
      ResponseModel res;
      res = await AuthUtils().login(email, password);
      if (!res.success) throw Error;
      res = await AuthUtils().fetchCurrentUser();
      if (!res.success) throw Error;
      setCurrentUser(res.content);
      return ResponseModel(success: true, message: 'Login successful.');
    } catch (e) {
      return ResponseModel(success: false, message: 'Login unsuccessful.');
    }
  }

  Future<ResponseModel> signOut() async {
    ResponseModel res = await AuthUtils().signOut();
    // the additional part
    if (res.success) {
      removeCurrentUser();
    }
    return res;
  }
}
