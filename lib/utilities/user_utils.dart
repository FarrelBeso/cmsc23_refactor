import 'package:todo_refactor/backend/auth_api.dart';
import 'package:todo_refactor/backend/user_api.dart';
import 'package:todo_refactor/model/constants.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/user_model.dart';

class UserUtils {
  Future<ResponseModel> getUser(String id) async {
    UserModel? usermodel;
    await UserAPI().getUser(id).then((value) {
      usermodel = value;
      if (usermodel == null) {
        print('User not found');
        return ResponseModel(success: false);
      }
    }).onError((error, stackTrace) {
      print(error);
      return ResponseModel(success: false);
    });
    return ResponseModel(success: true, content: usermodel);
  }

  // fetch users based on search
  // i.e., first and last name, or username
  Future<ResponseModel> getUsersByQuery(String stringQuery) async {
    Set<UserModel> searchResult = {};
    if (stringQuery.isEmpty) {
      searchResult.addAll(await UserAPI().getAllUsers());
    } else {
      searchResult.addAll(await UserAPI().getByUsername(stringQuery));
      searchResult.addAll(await UserAPI().getByLastName(stringQuery));
      searchResult.addAll(await UserAPI().getByFirstName(stringQuery));
    }

    return ResponseModel(success: true, content: searchResult.toList());
  }

  // check the status of two people from current user
  UserRelationStatus getStatus(UserModel currentUser, String otherId) {
    if (currentUser.friendIds!.contains(otherId)) {
      return UserRelationStatus.friend;
    } else if (currentUser.friendRequests!.contains(otherId)) {
      return UserRelationStatus.request;
    } else if (currentUser.pendingRequests!.contains(otherId)) {
      return UserRelationStatus.pending;
    } else {
      return UserRelationStatus.stranger;
    }
  }

  // friend request related
  // checking if operation is successful is a bit complicated
  Future<ResponseModel> addFriend(String otherId) async {
    await UserAPI().addFriend(AuthAPI().currentUser!.uid, otherId);
    return ResponseModel(success: true);
  }

  Future<ResponseModel> acceptRequest(String otherId) async {
    await UserAPI().acceptRequest(otherId, AuthAPI().currentUser!.uid);
    return ResponseModel(success: true);
  }

  Future<ResponseModel> rejectRequest(String otherId) async {
    await UserAPI().rejectRequest(otherId, AuthAPI().currentUser!.uid);
    return ResponseModel(success: true);
  }

  Future<ResponseModel> cancelRequest(String otherId) async {
    await UserAPI().cancelRequest(AuthAPI().currentUser!.uid, otherId);
    return ResponseModel(success: true);
  }

  Future<ResponseModel> removeFriend(String otherId) async {
    await UserAPI().acceptRequest(AuthAPI().currentUser!.uid, otherId);
    return ResponseModel(success: true);
  }
}
