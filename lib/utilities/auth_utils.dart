import 'package:todo_refactor/backend/auth_api.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/user_model.dart';

class AuthUtils {
  Future<ResponseModel> signIn(UserModel user, String password) async {
    return await AuthAPI().signIn(user, password);
  }

  Future<ResponseModel> login(String email, String password) async {
    return await AuthAPI().login(email, password);
  }

  Future<ResponseModel> signOut() async {
    return await AuthAPI().signOut();
  }

  Future<ResponseModel> fetchCurrentUser() async {
    return await AuthAPI().getCurrentUser();
  }
}
