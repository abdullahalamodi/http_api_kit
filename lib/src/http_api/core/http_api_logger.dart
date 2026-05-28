import 'package:http_interceptor/http_interceptor.dart';

abstract interface class HttpApiLogger {
  const HttpApiLogger();

  void logRequest(HttpApiRequestLog log);

  void logResponse(HttpApiResponseLog log);

  void logException(Object error, StackTrace stackTrace);
}

class NoopHttpApiLogger implements HttpApiLogger {
  const NoopHttpApiLogger();

  @override
  void logRequest(HttpApiRequestLog log) {}

  @override
  void logResponse(HttpApiResponseLog log) {}

  @override
  void logException(Object error, StackTrace stackTrace) {}
}

class HttpApiRequestLog {
  const HttpApiRequestLog({
    required this.uri,
    required this.method,
    required this.headers,
    this.body = const {},
    this.files = const [],
  });

  final Uri uri;
  final String method;
  final Map<String, String> headers;
  final Object? body;
  final List<MultipartFile> files;
}

class HttpApiResponseLog {
  const HttpApiResponseLog(this.response);

  final Response response;
}
