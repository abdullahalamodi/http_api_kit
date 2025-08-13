abstract interface class HttpApiException implements Exception {
  final String message;
  HttpApiException(this.message);
}
