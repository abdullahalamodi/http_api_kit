import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http_interceptor/http_interceptor.dart';

abstract interface class HttpApiLogger {
  const HttpApiLogger();

  void logRequest(HttpApiRequestLog req);

  void logResponse(HttpApiResponseLog res);

  void logException(Object error, StackTrace stackTrace);
}

class NoopHttpApiLogger implements HttpApiLogger {
  const NoopHttpApiLogger();

  @override
  void logRequest(HttpApiRequestLog req) {
    if (kDebugMode) log(req.uri.toString());
  }

  @override
  void logResponse(HttpApiResponseLog res) {
    if (kDebugMode) log(res.response.toString());
  }

  @override
  void logException(Object error, StackTrace stackTrace) {
    log('$error <-> <-> $stackTrace');
  }
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
