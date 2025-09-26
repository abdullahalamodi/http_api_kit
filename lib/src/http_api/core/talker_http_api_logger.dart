import 'dart:convert';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:talker_flutter/talker_flutter.dart';

class TalkerHttpApiLogger {
  static final TalkerHttpApiLogger _instance = TalkerHttpApiLogger._internal();
  factory TalkerHttpApiLogger({Talker? talker}) {
    _talker = talker ?? Talker();
    return _instance;
  }
  TalkerHttpApiLogger._internal();

  static late Talker _talker;

  void logRequest({
    required HttpRequestLog requestLog,
  }) {
    _talker.logCustom(requestLog);
  }

  void logResponse({
    required HttpResponseLog responseLog,
  }) {
    _talker.logCustom(responseLog);
  }
}

const encoder = JsonEncoder.withIndent('  ');

class HttpRequestLog extends TalkerLog {
  HttpRequestLog(
    super.url, {
    required this.method,
    required this.headers,
    required this.body,
    required this.files,
  });

  final String method;
  final Map<String, String>? headers;
  final Map<String, dynamic> body;
  final List<MultipartFile> files;

  @override
  AnsiPen get pen => (AnsiPen()..xterm(219));

  @override
  String get key => TalkerLogType.httpRequest.key;

  @override
  String generateTextMessage(
      {TimeFormat timeFormat = TimeFormat.timeAndSeconds}) {
    var msg = '[$title] [$method] $message';

    try {
      if (headers != null) {
        final prettyHeaders = encoder.convert(headers);
        msg += '\nHeaders: $prettyHeaders';
      }
      final prettyBody = encoder.convert(body);
      msg += '\nBody: $prettyBody';
    } catch (_) {
      msg += '\nError Pasrse Body: ';
      msg += '\nRow body: ${body.toString()}';
    }
    return msg;
  }
}

class HttpResponseLog extends TalkerLog {
  HttpResponseLog(this.response)
      : super(response.request?.url.toString() ?? 'NO_URL_!!');

  final Response response;

  @override
  AnsiPen get pen => (AnsiPen()..xterm(46));

  @override
  String get title => TalkerLogType.httpResponse.key;

  @override
  String generateTextMessage(
      {TimeFormat timeFormat = TimeFormat.timeAndSeconds}) {
    var msg = '[$title] [${response.request?.method}] $message';

    final headers = response.request?.headers;
    final body = response.body;

    msg += '\nStatus: ${response.statusCode}';

    try {
      if (headers != null) {
        final prettyHeaders = encoder.convert(headers);
        msg += '\nHeaders: $prettyHeaders';
      }

      final prettyBody = encoder.convert(jsonDecode(body));
      msg += '\nBody: $prettyBody';
    } catch (_) {
      msg += '\nError Pasrse Body: ';
      msg += '\nTry to print row body: $body';
    }
    return msg;
  }
}
