import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_refactor/backend/api_setting.dart';
import 'package:todo_refactor/backend/auth_api.dart';
import 'package:todo_refactor/fakefirebase/fake_firebase_auth.dart';
import 'package:todo_refactor/model/constants.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/user_model.dart';
import 'package:todo_refactor/utilities/user_utils.dart';

void main() {
  final usermodel = UserModel(
      id: '1234XXX',
      firstName: 'Lorem',
      lastName: 'Ipsum',
      username: 'LoremIpsum',
      email: 'lorem@ipsum.com',
      birthday: DateTime(2000, 1, 2),
      location: 'Philippines');

  final friend1 = UserModel(
      id: '5678XXX',
      firstName: 'Friend',
      lastName: 'One',
      username: 'friendone',
      email: 'friend@one.com',
      birthday: DateTime(2000, 1, 2),
      location: 'Philippines');

  final friend2 = UserModel(
      id: '9012XXX',
      firstName: 'Friend',
      lastName: 'Smith',
      username: 'friendtwo',
      email: 'friend@two.com',
      birthday: DateTime(2000, 1, 2),
      location: 'Philippines');

  final friend3 = UserModel(
      id: '3456XXX',
      firstName: 'Friend',
      lastName: 'Smith',
      username: 'friendthree',
      email: 'friend@three.com',
      birthday: DateTime(2000, 1, 2),
      location: 'Philippines');

  // reset the auth and db every test
  setUp(() {
    currentAuth = FakeFirebaseAuth();
    currentFirebase = FakeFirebaseFirestore();
  });

  group('Task Utils Test', () {
    test('Get user', () async {
      final userutils = UserUtils();
      ResponseModel res;
      // add user
      await addUser(usermodel, '12345678');
      res = await userutils.getUser(usermodel.id!);
      expect(res.content.id, usermodel.id);
    });

    test('Get user by query', () async {
      final userutils = UserUtils();
      ResponseModel res;
      List reslist;
      // add users
      await addUser(friend1, '12345678');
      await addUser(friend2, '12345678');
      await addUser(friend3, '12345678');
      // 1. no query (all users)
      res = await userutils.getUsersByQuery('');
      reslist = res.content.map((user) => user.id).toList();
      expect(reslist, hasLength(3));
      expect(reslist, containsAll([friend1.id, friend2.id, friend3.id]));
      // 2. by username
      res = await userutils.getUsersByQuery('friendone');
      reslist = res.content.map((user) => user.id).toList();
      expect(reslist, hasLength(1));
      expect(reslist, containsAll([friend1.id]));
      // 3. by lastname
      res = await userutils.getUsersByQuery('Smith');
      reslist = res.content.map((user) => user.id).toList();
      expect(reslist, hasLength(2));
      expect(reslist, containsAll([friend2.id, friend3.id]));
      // 4. by firstname
      res = await userutils.getUsersByQuery('Granny');
      reslist = res.content.map((user) => user.id).toList();
      expect(reslist, hasLength(0));
    });

    test('Friend Mechanics Check', () async {
      final userutils = UserUtils();
      // add users
      await addUser(usermodel, '12345678');
      await addUser(friend1, '12345678');
      await addUser(friend2, '12345678');
      await addUser(friend3, '12345678');
      // usermodel adds friend 1, 2, and 3
      await AuthAPI().login(usermodel.email!, '12345678');
      await userutils.addFriend(friend1.id!);
      await userutils.addFriend(friend2.id!);
      await userutils.addFriend(friend3.id!);
      // usermodel cancels friend 3 anyway
      await userutils.cancelRequest(friend3.id!);
      await AuthAPI().signOut();
      // friend 1 accepts while 2 rejects
      await AuthAPI().login(friend1.email!, '12345678');
      await userutils.acceptRequest(usermodel.id!);
      await AuthAPI().signOut();
      await AuthAPI().login(friend2.email!, '12345678');
      await userutils.rejectRequest(usermodel.id!);
      await AuthAPI().signOut();
      // usermodel signs in and removes friend 1
      await AuthAPI().login(usermodel.email!, '12345678');
      await userutils.removeFriend(friend1.id!);
      // at the end everyone should be a stranger
      final res = await userutils.getUser(usermodel.id!);
      expect(userutils.getStatus(res.content, friend1.id!),
          UserRelationStatus.stranger);
      expect(userutils.getStatus(res.content, friend2.id!),
          UserRelationStatus.stranger);
      expect(userutils.getStatus(res.content, friend3.id!),
          UserRelationStatus.stranger);
    });

    test('Friend Status', () async {
      final userutils = UserUtils();
      ResponseModel res;
      // add users
      await addUser(usermodel, '12345678');
      await addUser(friend1, '12345678');
      await addUser(friend2, '12345678');
      await addUser(friend3, '12345678');
      // usermodel is a friend of 1, pending of 2, and stranger for 3
      await AuthAPI().login(usermodel.email!, '12345678');
      await userutils.addFriend(friend1.id!);
      await userutils.addFriend(friend2.id!);
      // check and refetch the model
      res = await userutils.getUser(usermodel.id!);
      expect(userutils.getStatus(res.content, friend1.id!),
          UserRelationStatus.pending);
      expect(userutils.getStatus(res.content, friend2.id!),
          UserRelationStatus.pending);
      await AuthAPI().signOut();
      await AuthAPI().login(friend1.email!, '12345678');
      await userutils.acceptRequest(usermodel.id!);
      await AuthAPI().signOut();
      await AuthAPI().login(usermodel.email!, '12345678');
      // check and refetch the model
      res = await userutils.getUser(usermodel.id!);
      expect(userutils.getStatus(res.content, friend1.id!),
          UserRelationStatus.friend);
      expect(userutils.getStatus(res.content, friend3.id!),
          UserRelationStatus.stranger);
      // perspective of friend 2
      await AuthAPI().signOut();
      await AuthAPI().login(friend2.email!, '12345678');
      res = await userutils.getUser(friend2.id!);
      expect(userutils.getStatus(res.content, usermodel.id!),
          UserRelationStatus.request);
    });
  });
}

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
