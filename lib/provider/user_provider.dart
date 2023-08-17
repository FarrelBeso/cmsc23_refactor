import 'package:flutter/foundation.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/utilities/user_utils.dart';

class UserProvider extends ChangeNotifier {
  Future<ResponseModel> searchUsers(String stringQuery) async {
    return await UserUtils().getUsersByQuery(stringQuery);
  }

  // friend request related
  // checking if operation is successful is a bit complicated
  // make sure to update the provider via wrappers
  Future<ResponseModel> addFriend(String otherId) async {
    await UserUtils().addFriend(otherId);
    return ResponseModel(success: true);
  }

  Future<ResponseModel> acceptRequest(String otherId) async {
    await UserUtils().acceptRequest(otherId);
    return ResponseModel(success: true);
  }

  Future<ResponseModel> rejectRequest(String otherId) async {
    await UserUtils().rejectRequest(otherId);
    return ResponseModel(success: true);
  }

  Future<ResponseModel> cancelRequest(String otherId) async {
    await UserUtils().cancelRequest(otherId);
    return ResponseModel(success: true);
  }

  Future<ResponseModel> removeFriend(String otherId) async {
    await UserUtils().removeFriend(otherId);
    return ResponseModel(success: true);
  }
}
