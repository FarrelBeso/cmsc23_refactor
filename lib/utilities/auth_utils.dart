import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_refactor/backend/auth_api.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/user_model.dart';

class AuthUtils {
  Future<ResponseModel> signIn(UserModel user, String password) async {
    try {
      await AuthAPI().signIn(user, password);

      return ResponseModel(success: true, message: 'Successfully signed in');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return ResponseModel(success: false, message: 'Email already in use');
      }
    } catch (e) {
      print(e);
    }
    return ResponseModel(success: false, message: 'Unknown sign-in error');
  }

  Future<ResponseModel> login(String email, String password) async {
    try {
      await AuthAPI().login(email, password);

      return ResponseModel(success: true, message: 'Successfully logged in');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return ResponseModel(
            success: false, message: 'User or email not found');
      } else if (e.code == 'wrong-password') {
        return ResponseModel(success: false, message: 'Incorrect password');
      }
    } catch (e) {
      print(e);
    }
    return ResponseModel(success: false, message: 'Unknown login error');
  }

  Future<ResponseModel> signOut() async {
    try {
      await AuthAPI().signOut();

      return ResponseModel(success: true, message: 'Successfully signed out');
    } catch (e) {
      print(e);
    }
    return ResponseModel(success: false, message: 'Unknown sign out error');
  }

  Future<ResponseModel> fetchCurrentUser() async {
    if (AuthAPI().currentUser == null) {
      return ResponseModel(
          success: false, message: 'Failed to fetch current user');
    } else {
      return ResponseModel(
          success: true, content: await AuthAPI().getCurrentUser());
    }
  }
}
