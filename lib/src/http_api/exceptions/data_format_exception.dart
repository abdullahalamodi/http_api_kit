import 'http_api_exception.dart';

class DataFormatException implements HttpApiException {
  @override
  final String message;

  DataFormatException(this.message);

  @override
  String toString() {
    return message;
  }
}
