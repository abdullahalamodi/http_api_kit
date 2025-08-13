import 'http_api_exception.dart';

class UnknownException implements HttpApiException {
  @override
  final String message;

  UnknownException(this.message);

  @override
  String toString() {
    return message;
  }
}
