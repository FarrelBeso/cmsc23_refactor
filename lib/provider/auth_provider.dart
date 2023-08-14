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

  // wrappers
  Future<ResponseModel> signIn(UserModel user, String password) async {
    ResponseModel res = await AuthUtils().signIn(user, password);
    // the additional part
    if (res.success) {
      currentUser = user;
    }
    return res;
  }

  Future<ResponseModel> login(String email, String password) async {
    ResponseModel res = await AuthUtils().login(email, password);
    // the additional part
    if (res.success) {
      currentUser = user;
    }
    return res;
  }

  Future<ResponseModel> signOut() async {
    ResponseModel res = await AuthUtils().signOut();
    // the additional part
    if (res.success) {
      currentUser = null;
    }
    return res;
  }
}
