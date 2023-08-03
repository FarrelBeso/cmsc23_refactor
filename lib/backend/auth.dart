import 'dart:js_interop';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_refactor/model/user_model.dart';

class AuthAPI {
  final db = FirebaseFirestore.instance;
  User? get currentUser => FirebaseAuth.instance.currentUser;

  Stream<User?> get authStateChanges =>
      FirebaseAuth.instance.authStateChanges();

  Future<void> signIn(UserModel usermodel, String password) async {
    final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: usermodel.email!, password: password);
    usermodel.id = result.user!.uid; // set the user here
    await addToDatabase(usermodel);
  }

  Future<void> login(String email, String password) async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  // database related actions
  Future<void> addToDatabase(UserModel usermodel) async {
    final docRef = db
        .collection("users")
        .withConverter(
            fromFirestore: UserModel.fromFirestore,
            toFirestore: (UserModel model, options) => model.toFirestore())
        .doc(usermodel.id);
    await docRef.set(usermodel);
  }

  Future<UserModel?> getCurrentUser() async {
    if (currentUser == null) return null;
    String id = currentUser!.uid;
    final docRef = db.collection("users").doc(id).withConverter(
        fromFirestore: UserModel.fromFirestore,
        toFirestore: (UserModel model, options) => model.toFirestore());
    final docSnap = await docRef.get();
    final usermodel = docSnap.data();
    return usermodel;
  }
}
