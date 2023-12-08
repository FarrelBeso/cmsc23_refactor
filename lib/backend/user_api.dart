import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/user_model.dart';

import 'api_setting.dart';

class UserAPI {
  final db = currentFirebase;

  // get the user info
  Future<ResponseModel> getUser(String id) async {
    try {
      final docRef = db.collection("users").doc(id).withConverter(
          fromFirestore: UserModel.fromFirestore,
          toFirestore: (UserModel model, _) => model.toFirestore());
      final docSnap = await docRef.get();
      final usermodel = docSnap.data();
      return ResponseModel(
          success: true,
          message: 'Successfully fetched user.',
          content: usermodel);
    } catch (e) {
      return ResponseModel(success: false, message: 'Failed to fetch user.');
    }
  }

  // update that the user has a new task that they made
  Future<ResponseModel> addTaskId(String taskId) async {
    try {
      final docRef = db.collection("users").doc(currentAuth.currentUser!.uid);
      await docRef.update({
        "taskOwnIds": FieldValue.arrayUnion([taskId])
      });
      return ResponseModel(success: true, message: 'Task id added.');
    } catch (e) {
      print(e);
      return ResponseModel(success: false, message: 'Failed to add task id.');
    }
  }

  // remove the task from id
  Future<ResponseModel> removeTaskId(String taskId) async {
    try {
      final docRef = db.collection("users").doc(currentAuth.currentUser!.uid);
      await docRef.update({
        "taskOwnIds": FieldValue.arrayRemove([taskId])
      });
      return ResponseModel(success: true, message: 'Task id removed.');
    } catch (e) {
      return ResponseModel(
          success: false, message: 'Failed to remove task id.');
    }
  }

  // get all users of related string query
  // via their first and last name or username
  Future<ResponseModel> getByFirstName(String stringQuery) async {
    try {
      List<UserModel> userlist = [];
      final collectionRef = db.collection("users");
      final query = collectionRef.where("firstName", isEqualTo: stringQuery);
      await query.get().then((querySnapshot) {
        userlist = (querySnapshot.docs)
            .map((doc) => UserModel.fromFirestore(doc, null))
            .toList();
      });
      return ResponseModel(
          success: true,
          message: 'Successfully fetched query.',
          content: userlist);
    } catch (e) {
      return ResponseModel(
          success: false, message: 'Failed to fetch query (first name).');
    }
  }

  Future<ResponseModel> getByLastName(String stringQuery) async {
    try {
      List<UserModel> userlist = [];
      final collectionRef = db.collection("users");
      final query = collectionRef.where("lastName", isEqualTo: stringQuery);
      await query.get().then((querySnapshot) {
        userlist = (querySnapshot.docs)
            .map((doc) => UserModel.fromFirestore(doc, null))
            .toList();
      });
      return ResponseModel(
          success: true,
          message: 'Successfully fetched query.',
          content: userlist);
    } catch (e) {
      return ResponseModel(
          success: false, message: 'Failed to fetch query (last name).');
    }
  }

  Future<ResponseModel> getByUsername(String stringQuery) async {
    try {
      List<UserModel> userlist = [];
      final collectionRef = db.collection("users");
      final query = collectionRef.where("username", isEqualTo: stringQuery);
      await query.get().then((querySnapshot) {
        userlist = (querySnapshot.docs)
            .map((doc) => UserModel.fromFirestore(doc, null))
            .toList();
      });
      return ResponseModel(
          success: true,
          message: 'Successfully fetched query.',
          content: userlist);
    } catch (e) {
      return ResponseModel(
          success: false, message: 'Failed to fetch query (username).');
    }
  }

  // get all users
  Future<ResponseModel> getAllUsers() async {
    try {
      List<UserModel> userlist = [];
      final collectionRef = db.collection("users");
      await collectionRef.get().then((querySnapshot) {
        userlist = (querySnapshot.docs)
            .map((doc) => UserModel.fromFirestore(doc, null))
            .toList();
      });
      return ResponseModel(
          success: true,
          message: 'Successfully fetched all users.',
          content: userlist);
    } catch (e) {
      return ResponseModel(
          success: false, message: 'Failed to fetch all users.');
    }
  }

  // friend related functions
  // the perspective is on sender
  Future<ResponseModel> addFriend(String senderId, String receiverId) async {
    try {
      final senderRef = db.collection("users").doc(senderId);
      final receiverRef = db.collection("users").doc(receiverId);
      // the sender would modify pending
      await senderRef.update({
        "pendingRequests": FieldValue.arrayUnion([receiverId])
      });
      // the receiver would modify requests
      await receiverRef.update({
        "friendRequests": FieldValue.arrayUnion([senderId])
      });
      return ResponseModel(success: true, message: 'Friend added.');
    } catch (e) {
      return ResponseModel(success: false, message: 'Failed to add friend.');
    }
  }

  // the perspective is on receiver
  Future<ResponseModel> acceptRequest(
      String senderId, String receiverId) async {
    try {
      final senderRef = db.collection("users").doc(senderId);
      final receiverRef = db.collection("users").doc(receiverId);
      // sender function
      await senderRef.update({
        "pendingRequests": FieldValue.arrayRemove([receiverId])
      });
      await senderRef.update({
        "friendIds": FieldValue.arrayUnion([receiverId])
      });
      // receiver function
      await receiverRef.update({
        "friendRequests": FieldValue.arrayRemove([senderId])
      });
      await receiverRef.update({
        "friendIds": FieldValue.arrayUnion([senderId])
      });
      return ResponseModel(success: true, message: 'Request accepted.');
    } catch (e) {
      return ResponseModel(
          success: false, message: 'Failed to accept request.');
    }
  }

  // the perspective is on receiver
  Future<ResponseModel> rejectRequest(
      String senderId, String receiverId) async {
    try {
      final senderRef = db.collection("users").doc(senderId);
      final receiverRef = db.collection("users").doc(receiverId);
      // sender function
      await senderRef.update({
        "pendingRequests": FieldValue.arrayRemove([receiverId])
      });
      // receiver function
      await receiverRef.update({
        "friendRequests": FieldValue.arrayRemove([senderId])
      });
      return ResponseModel(success: true, message: 'Request rejected.');
    } catch (e) {
      return ResponseModel(
          success: false, message: 'Failed to reject request.');
    }
  }

  // the perspective is on sender
  Future<ResponseModel> cancelRequest(
      String senderId, String receiverId) async {
    try {
      final senderRef = db.collection("users").doc(senderId);
      final receiverRef = db.collection("users").doc(receiverId);
      // sender function
      await senderRef.update({
        "pendingRequests": FieldValue.arrayRemove([receiverId])
      });
      // receiver function
      await receiverRef.update({
        "friendRequests": FieldValue.arrayRemove([senderId])
      });
      return ResponseModel(success: true, message: 'Request canceled.');
    } catch (e) {
      return ResponseModel(
          success: false, message: 'Failed to cancel request.');
    }
  }

  // the perspective is on sender
  Future<ResponseModel> removeFriend(String senderId, String receiverId) async {
    try {
      final senderRef = db.collection("users").doc(senderId);
      final receiverRef = db.collection("users").doc(receiverId);
      // sender function
      await senderRef.update({
        "friendIds": FieldValue.arrayRemove([receiverId])
      });
      // receiver function
      await receiverRef.update({
        "friendIds": FieldValue.arrayRemove([senderId])
      });
      return ResponseModel(success: true, message: 'Removed friend.');
    } catch (e) {
      return ResponseModel(success: false, message: 'Failed to remove friend.');
    }
  }
}
