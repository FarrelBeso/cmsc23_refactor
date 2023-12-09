import 'package:todo_refactor/backend/auth_api.dart';
import 'package:todo_refactor/backend/user_api.dart';
import 'package:todo_refactor/model/constants.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/model/user_model.dart';

class UserUtils {
  Future<ResponseModel> getUser(String id) async {
    try {
      ResponseModel res;
      res = await UserAPI().getUser(id);
      if (!res.success) throw Error;
      if (res.content == null) {
        return ResponseModel(success: true, message: 'User not found.');
      } else {
        return ResponseModel(
            success: true, message: 'User found.', content: res.content);
      }
    } catch (e) {
      return ResponseModel(success: false, message: 'Failed to fetch user.');
    }
  }

  // fetch users based on search
  // i.e., first and last name, or username
  Future<ResponseModel> getUsersByQuery(String stringQuery) async {
    try {
      ResponseModel res;
      Set searchResult = {};
      if (stringQuery.isEmpty) {
        res = await UserAPI().getAllUsers();
        if (!res.success) throw Error;
        searchResult.addAll(res.content);
      } else {
        res = await UserAPI().getByUsername(stringQuery);
        if (!res.success) throw Error;
        searchResult.addAll(res.content);

        res = await UserAPI().getByLastName(stringQuery);
        if (!res.success) throw Error;
        searchResult.addAll(res.content);

        res = await UserAPI().getByFirstName(stringQuery);
        if (!res.success) throw Error;
        searchResult.addAll(res.content);
      }

      return ResponseModel(
          success: true,
          message: 'User search finished.',
          content: searchResult.toList());
    } catch (e) {
      return ResponseModel(success: false, message: 'Failed querying users.');
    }
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
    return await UserAPI().addFriend(AuthAPI().currentUser!.uid, otherId);
  }

  Future<ResponseModel> acceptRequest(String otherId) async {
    return await UserAPI().acceptRequest(otherId, AuthAPI().currentUser!.uid);
  }

  Future<ResponseModel> rejectRequest(String otherId) async {
    return await UserAPI().rejectRequest(otherId, AuthAPI().currentUser!.uid);
  }

  Future<ResponseModel> cancelRequest(String otherId) async {
    return await UserAPI().cancelRequest(AuthAPI().currentUser!.uid, otherId);
  }

  Future<ResponseModel> removeFriend(String otherId) async {
    return await UserAPI().removeFriend(AuthAPI().currentUser!.uid, otherId);
  }
}
