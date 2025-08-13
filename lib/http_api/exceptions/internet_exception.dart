import 'http_api_exception.dart';

class InternetException implements HttpApiException {
  @override
  final String message;

  InternetException(this.message);

  @override
  String toString() {
    return message;
  }
}
