// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http_api_kit/http_api/core/talker_http_api_logger.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:talker_flutter/talker_flutter.dart';

const _enableTagLogger = true;
const _enableHttpLogger = true;

final talker = TalkerFlutter.init();

void openLoger(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => TalkerScreen(talker: talker),
  ));
}

class CustomLogger {
  static void tagLogger({required String tag, required dynamic data}) {
    if (kDebugMode && _enableTagLogger) {
      talker.info(data);
    }
  }

  static final _httpApiTalker = TalkerHttpApiLogger(talker: talker);

  static void requestLogger({
    required Uri? uri,
    required String method,
    required Map<String, String>? headers,
    Map<String, dynamic> body = const {},
    List<MultipartFile> files = const [],
  }) {
    if (kDebugMode && _enableHttpLogger) {
      _httpApiTalker.logRequest(
          requestLog: HttpRequestLog(
        uri.toString(),
        method: method,
        headers: headers,
        body: body,
        files: files,
      ));
    }
  }

  static void responseLogger(
    Response response,
  ) {
    if (kDebugMode && _enableHttpLogger) {
      _httpApiTalker.logResponse(
        responseLog: HttpResponseLog(response),
      );
    }
  }

  static void exceptionLogger({
    String? msg,
    required Object error,
    required StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      talker.handle(
        error,
        stackTrace,
        msg,
      );
    }
  }
}
