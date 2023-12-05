import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_refactor/fakefirebase/fake_firebase_auth.dart';

// fake
var currentAuth = FakeFirebaseAuth();
var currentFirebase = FakeFirebaseFirestore();

// actual
// final currentAuth = FirebaseAuth.instance;
// final currentFirebase = currentFirebase;
