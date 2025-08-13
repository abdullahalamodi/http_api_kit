import 'http_api_exception.dart';

class ServerException implements HttpApiException {
  @override
  final String message;

  final int statusCode;

  ServerException(this.message, {this.statusCode = 0});

  @override
  String toString() {
    return message;
  }
}
