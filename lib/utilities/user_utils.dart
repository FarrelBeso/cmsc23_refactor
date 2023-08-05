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
}
