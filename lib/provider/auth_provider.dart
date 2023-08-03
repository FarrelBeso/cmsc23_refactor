import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_refactor/backend/auth.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? currentuser;

  void setUser(UserModel user) {
    currentuser = user;
    notifyListeners();
  }

  void removeUser() {
    currentuser = null;
    notifyListeners();
  }

  Future<ResponseModel> signIn(UserModel user, String password) async {
    try {
      await AuthAPI().signIn(user.email!, password);
      // set to current user here
      return ResponseModel(success: true, message: 'Successfully signed in');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return ResponseModel(success: false, message: 'Email already in use.');
      }
    } catch (e) {
      print(e);
    }
    return ResponseModel(success: false, message: 'Unknown sign-in error');
  }

  Future<ResponseModel> login(String email, String password) async {
    try {
      await AuthAPI().login(email, password);
      // set to current user here
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
      // remove the current user here
      return ResponseModel(success: true, message: 'Successfully signed out');
    } catch (e) {
      print(e);
    }
    return ResponseModel(success: false, message: 'Unknown sign out error');
  }
}
