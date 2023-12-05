import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/user_model.dart';

import 'api_setting.dart';

class AuthAPI {
  final db = currentFirebase;
  User? get currentUser => currentAuth.currentUser;

  Stream<User?> get authStateChanges => currentAuth.authStateChanges();

  Future<ResponseModel> signIn(UserModel usermodel, String password) async {
    try {
      final result = await currentAuth.createUserWithEmailAndPassword(
          email: usermodel.email!, password: password);
      usermodel.id = result.user!.uid; // set the user here
      final dbres = await addToDatabase(usermodel);
      if (!dbres.success) throw Error;
      return ResponseModel(success: true, message: 'Successfully signed in.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return ResponseModel(success: false, message: 'Email already in use');
      }
      return ResponseModel(
          success: false,
          message: 'Failed to sign in (Unknown Firebase Auth Error).');
    } catch (e) {
      return ResponseModel(
          success: false, message: 'Failed to sign in (Unknown Error).');
    }
  }

  Future<ResponseModel> login(String email, String password) async {
    try {
      await currentAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return ResponseModel(success: true, message: 'Successfully logged in.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return ResponseModel(
            success: false, message: 'User or email not found');
      } else if (e.code == 'wrong-password') {
        return ResponseModel(success: false, message: 'Incorrect password');
      }
      return ResponseModel(
          success: false, message: 'Login Error (Unknown Firebase Auth Error)');
    } catch (e) {
      return ResponseModel(
          success: false, message: 'Failed to log in (Unknown Error).');
    }
  }

  Future<ResponseModel> signOut() async {
    try {
      await currentAuth.signOut();
      return ResponseModel(success: true, message: 'Successfully signed out.');
    } catch (e) {
      return ResponseModel(success: false, message: 'Failed to sign out.');
    }
  }

  // database related actions
  Future<ResponseModel> addToDatabase(UserModel usermodel) async {
    try {
      final docRef = db
          .collection("users")
          .withConverter(
              fromFirestore: UserModel.fromFirestore,
              toFirestore: (UserModel model, options) => model.toFirestore())
          .doc(usermodel.id);
      await docRef.set(usermodel);
      return ResponseModel(success: true);
    } catch (e) {
      return ResponseModel(success: false);
    }
  }

  Future<ResponseModel> getCurrentUser() async {
    try {
      if (currentUser == null) {
        return ResponseModel(
            success: true, message: 'User not found', content: null);
      }
      String id = currentUser!.uid;
      final docRef = db.collection("users").doc(id).withConverter(
          fromFirestore: UserModel.fromFirestore,
          toFirestore: (UserModel model, _) => model.toFirestore());
      final docSnap = await docRef.get();
      final usermodel = docSnap.data();
      return ResponseModel(success: true, content: usermodel);
    } catch (e) {
      return ResponseModel(
          success: false, message: 'Failed to fetch current user.');
    }
  }
}
