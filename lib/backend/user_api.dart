import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_refactor/model/user_model.dart';

class UserAPI {
  final db = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  // get the user info
  Future<UserModel?> getUser(String id) async {
    final docRef = db.collection("users").doc(id).withConverter(
        fromFirestore: UserModel.fromFirestore,
        toFirestore: (UserModel model, _) => model.toFirestore());
    final docSnap = await docRef.get();
    final usermodel = docSnap.data();
    return usermodel;
  }

  // update that the user has a new task that they made
  Future<void> addTaskId(String taskId) async {
    final docRef = db.collection("users").doc(_currentUser!.uid);
    await docRef.update({
      "taskOwnIds": FieldValue.arrayUnion([taskId])
    });
  }

  // remove the task from id
  Future<void> removeTaskId(String taskId) async {
    final docRef = db.collection("users").doc(_currentUser!.uid);
    await docRef.update({
      "taskOwnIds": FieldValue.arrayRemove([taskId])
    });
  }

  // get all users of related string query
  // via their first and last name or username
  Future<List<UserModel>> getByFirstName(String stringQuery) async {
    List<UserModel> userlist = [];
    final collectionRef = db.collection("users");
    final query = collectionRef.where("firstName", isEqualTo: stringQuery);
    await query.get().then((querySnaphost) {
      userlist = (querySnaphost.docs)
          .map((doc) => UserModel.fromFirestore(doc, null))
          .toList();
    });
    return userlist;
  }

  Future<List<UserModel>> getByLastName(String stringQuery) async {
    List<UserModel> userlist = [];
    final collectionRef = db.collection("users");
    final query = collectionRef.where("lastName", isEqualTo: stringQuery);
    await query.get().then((querySnaphost) {
      userlist = (querySnaphost.docs)
          .map((doc) => UserModel.fromFirestore(doc, null))
          .toList();
    });
    return userlist;
  }

  Future<List<UserModel>> getByUsername(String stringQuery) async {
    List<UserModel> userlist = [];
    final collectionRef = db.collection("users");
    final query = collectionRef.where("username", isEqualTo: stringQuery);
    await query.get().then((querySnaphost) {
      userlist = (querySnaphost.docs)
          .map((doc) => UserModel.fromFirestore(doc, null))
          .toList();
    });
    return userlist;
  }

  // get all users
  Future<List<UserModel>> getAllUsers() async {
    List<UserModel> userlist = [];
    final collectionRef = db.collection("users");
    await collectionRef.get().then((querySnaphost) {
      userlist = (querySnaphost.docs)
          .map((doc) => UserModel.fromFirestore(doc, null))
          .toList();
    });
    return userlist;
  }

  // friend related functions
  // the perspective is on sender
  Future<void> addFriend(String senderId, String receiverId) async {
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
  }

  // the perspective is on receiver
  Future<void> acceptRequest(String senderId, String receiverId) async {
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
  }

  // the perspective is on receiver
  Future<void> rejectRequest(String senderId, String receiverId) async {
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
  }

  // the perspective is on sender
  Future<void> cancelRequest(String senderId, String receiverId) async {
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
  }

  // the perspective is on sender
  Future<void> removeFriend(String senderId, String receiverId) async {
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
  }
}
