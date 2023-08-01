import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_refactor/backend/auth.dart';
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

  Future<void> signIn(UserModel user, String password) async {
    await AuthAPI().signIn(user.email!, password);
  }

  Future<void> login(String email, String password) async {
    await AuthAPI().login(email, password);
  }

  Future<void> signOut() async {
    await AuthAPI().signOut();
  }
}
