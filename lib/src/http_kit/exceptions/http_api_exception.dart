abstract interface class HttpApiException implements Exception {
  final String message;
  const HttpApiException(this.message);
}
