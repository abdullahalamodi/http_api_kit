abstract interface class ResponseModelInterface {
  const ResponseModelInterface();
  int get statusCode;
  bool get success;
  String? get message;
  dynamic get data;
}
