import 'package:flutter/foundation.dart';
import 'package:todo_refactor/model/localmail_model.dart';
import 'package:todo_refactor/model/response_model.dart';
import 'package:todo_refactor/utilities/localmail_utils.dart';

class LocalMailProvider extends ChangeNotifier {
  List<LocalMailModel>? currentMailFeed;

  List<LocalMailModel>? get mailFeed => currentMailFeed;

  // set and remove feed
  void setCurrentFeed(List<LocalMailModel> feed) {
    currentMailFeed = feed;
    notifyListeners();
  }

  void clearCurrentField() {
    currentMailFeed = null;
    notifyListeners();
  }

  Future<ResponseModel> updateFeed() async {
    ResponseModel res = await LocalMailUtils().getLocalMailFromUser();
    if (res.success) {
      setCurrentFeed(res.content);
    }
    return res;
  }
}
