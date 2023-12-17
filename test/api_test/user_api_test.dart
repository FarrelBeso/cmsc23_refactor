import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_refactor/backend/api_setting.dart';
import 'package:todo_refactor/backend/auth_api.dart';
import 'package:todo_refactor/backend/user_api.dart';
import 'package:todo_refactor/fakefirebase/fake_firebase_auth.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/user_model.dart';

void main() {
  final usermodel = UserModel(
    id: '1234XXX',
    firstName: 'Lorem',
    lastName: 'Ipsum',
    username: 'LoremIpsum',
    email: 'lorem@ipsum.com',
    birthday: DateTime(2000, 1, 2),
    location: 'Philippines',
  );

  final user1 = UserModel(
    id: '1234XXX',
    firstName: 'Apple',
    lastName: 'Xylophone',
    username: 'UserOne',
    email: 'user@one.com',
    birthday: DateTime(2000, 1, 2),
    location: 'Philippines',
  );

  final user2 = UserModel(
    id: '5678XXX',
    firstName: 'Apple',
    lastName: 'Yacht',
    username: 'UserTwo',
    email: 'user@two.com',
    birthday: DateTime(2000, 1, 2),
    location: 'Philippines',
  );

  final user3 = UserModel(
    id: '9012XXX',
    firstName: 'Carrot',
    lastName: 'Yacht',
    username: 'UserThree',
    email: 'user@three.com',
    birthday: DateTime(2000, 1, 2),
    location: 'Philippines',
  );

  // reset the auth and db every test
  setUp(() {
    currentAuth = FakeFirebaseAuth();
    currentFirebase = FakeFirebaseFirestore();
  });

  group('User API Test', () {
    test('Get User', () async {
      final userapi = UserAPI();
      // inject
      await addUser(usermodel, '12345678');
      final res = await userapi.getUser(usermodel.id!);
      expect(res.content, isNotNull);
      expect(res.content.email, usermodel.email);
    });

    test('Add task id, and remove task id', () async {
      final userapi = UserAPI();
      // autologin
      await setToLogin(usermodel, '12345678');
      var res = await userapi.addTaskId('12XX');
      expect(res.success, true);
      var usercheck = await userapi.getUser(usermodel.id!);
      expect(usercheck.content.taskOwnIds, ['12XX']);

      res = await userapi.removeTaskId('12XX');
      expect(res.success, true);
      usercheck = await userapi.getUser(usermodel.id!);
      expect(usercheck.content.taskOwnIds, []);
    });

    test('User querying', () async {
      final userapi = UserAPI();
      // inject users
      await addUser(user1, '12345678');
      await addUser(user2, '12345678');
      await addUser(user3, '12345678');
      ResponseModel res;
      List idlist;
      // 1. first name test
      res = await userapi.getByFirstName('Apple');
      expect(res.success, true);
      expect(res.content.length, 2);
      // extract the content
      idlist = res.content.map((user) => user.id).toList();
      expect(idlist, containsAll([user1.id, user2.id]));
      // 2. last name test
      res = await userapi.getByLastName('Yacht');
      expect(res.success, true);
      expect(res.content.length, 2);
      // extract content
      idlist = res.content.map((user) => user.id).toList();
      expect(idlist, containsAll([user2.id, user3.id]));
      // 3. username test
      res = await userapi.getByUsername('UserOne');
      expect(res.success, true);
      expect(res.content.length, 1);
      // extract content
      idlist = res.content.map((user) => user.id).toList();
      expect(idlist, contains(user1.id));
      // 4. no user found test
      res = await userapi.getByUsername('UserZero');
      expect(res.success, true);
      expect(res.content.length, 0);
      // 5. get all users
      res = await userapi.getAllUsers();
      expect(res.success, true);
      expect(res.content.length, 3);
      // extract content
      idlist = res.content.map((user) => user.id).toList();
      expect(idlist, containsAll([user1.id, user2.id, user3.id]));
    });

    test('Add friend, accept request, then remove friend', () async {
      final userapi = UserAPI();
      // inject users
      await addUser(user1, '12345678');
      await addUser(user2, '12345678');
      ResponseModel res;
      // 1. user 1 adds user 2 as friend
      await AuthAPI().login(user1.email!, '12345678');
      res = await userapi.addFriend(user1.id!, user2.id!);
      expect(res.success, true);
      // check if it's in the db
      // check pending and friend requests
      res = await userapi.getUser(user1.id!);
      expect(res.content.pendingRequests, contains(user2.id));
      res = await userapi.getUser(user2.id!);
      expect(res.content.friendRequests, contains(user1.id));

      // 2. user 2 accepts request
      await AuthAPI().signOut();
      await AuthAPI().login(user2.email!, '12345678');
      res = await userapi.acceptRequest(user1.id!, user2.id!);
      expect(res.success, true);
      res = await userapi.getUser(user1.id!);
      expect(res.content.friendIds, contains(user2.id));
      expect(res.content.pendingRequests, isEmpty);
      res = await userapi.getUser(user2.id!);
      expect(res.content.friendIds, contains(user1.id));
      expect(res.content.friendRequests, isEmpty);

      // 3. user 2 removes user 1 as friend
      res = await userapi.removeFriend(user2.id!, user1.id!);
      expect(res.success, true);
      res = await userapi.getUser(user1.id!);
      expect(res.content.friendIds, isEmpty);
      res = await userapi.getUser(user2.id!);
      expect(res.content.friendIds, isEmpty);
    });

    test('Cancel Request', () async {
      final userapi = UserAPI();
      // inject users
      await addUser(user1, '12345678');
      await addUser(user2, '12345678');
      ResponseModel res;
      // 1. user 1 adds user 2 as friend
      await AuthAPI().login(user1.email!, '12345678');
      res = await userapi.addFriend(user1.id!, user2.id!);
      expect(res.success, true);
      // check if it's in the db
      // check pending and friend requests
      res = await userapi.getUser(user1.id!);
      expect(res.content.pendingRequests, contains(user2.id));
      res = await userapi.getUser(user2.id!);
      expect(res.content.friendRequests, contains(user1.id));

      // 2. user 1 cancels request
      res = await userapi.cancelRequest(user1.id!, user2.id!);
      expect(res.success, true);
      // check if it's in the db
      // check pending and friend requests
      res = await userapi.getUser(user1.id!);
      expect(res.content.pendingRequests, isEmpty);
      expect(res.content.friendIds, isEmpty);
      res = await userapi.getUser(user2.id!);
      expect(res.content.friendRequests, isEmpty);
      expect(res.content.friendIds, isEmpty);
    });

    test('Reject request', () async {
      final userapi = UserAPI();
      // inject users
      await addUser(user1, '12345678');
      await addUser(user2, '12345678');
      ResponseModel res;
      // 1. user 1 adds user 2 as friend
      await AuthAPI().login(user1.email!, '12345678');
      res = await userapi.addFriend(user1.id!, user2.id!);
      expect(res.success, true);
      // check if it's in the db
      // check pending and friend requests
      res = await userapi.getUser(user1.id!);
      expect(res.content.pendingRequests, contains(user2.id));
      res = await userapi.getUser(user2.id!);
      expect(res.content.friendRequests, contains(user1.id));

      // 2. user 2 rejects request
      await AuthAPI().signOut();
      await AuthAPI().login(user2.email!, '12345678');
      res = await userapi.rejectRequest(user1.id!, user2.id!);
      expect(res.success, true);
      res = await userapi.getUser(user1.id!);
      expect(res.content.friendIds, isEmpty);
      expect(res.content.pendingRequests, isEmpty);
      res = await userapi.getUser(user2.id!);
      expect(res.content.friendIds, isEmpty);
      expect(res.content.friendRequests, isEmpty);
    });
  });
}

// cheat functions
Future<void> setToLogin(UserModel usermodel, String password) async {
  addUser(usermodel, password);
  await AuthAPI().login(usermodel.email!, password);
}

Future<void> addUser(UserModel usermodel, String password) async {
  currentAuth.addNewAccount(usermodel.email!, password, uid: usermodel.id);
  final docRef = currentFirebase
      .collection("users")
      .withConverter(
          fromFirestore: UserModel.fromFirestore,
          toFirestore: (UserModel model, options) => model.toFirestore())
      .doc(usermodel.id);
  await docRef.set(usermodel);
}
