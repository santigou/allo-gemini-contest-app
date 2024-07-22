class ResponseModel{
  bool isError;
  String message;
  dynamic result;

  ResponseModel({
    required this.isError,
    required this.message,
    this.result
  });
}