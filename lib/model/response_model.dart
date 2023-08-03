// model for handling async responses

class ResponseModel {
  bool success;
  String? message;
  // content
  dynamic content;

  ResponseModel({required this.success, this.message, this.content});
}
