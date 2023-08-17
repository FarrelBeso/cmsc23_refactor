import 'package:todo_refactor/backend/user_api.dart';
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
}
