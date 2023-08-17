import 'package:flutter/foundation.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/utilities/user_utils.dart';

class UserProvider extends ChangeNotifier {
  Future<ResponseModel> searchUsers(String stringQuery) async {
    return await UserUtils().getUsersByQuery(stringQuery);
  }
}
