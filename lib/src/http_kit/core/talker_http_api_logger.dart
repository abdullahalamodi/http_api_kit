import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'http_api_logger.dart';

class TalkerHttpApiLoggerAdapter implements HttpApiLogger {
  TalkerHttpApiLoggerAdapter({Talker? talker}) : _talker = talker ?? Talker();

  final Talker _talker;

  @override
  void logRequest(HttpApiRequestLog req) {
    if (kDebugMode) _talker.logCustom(_TalkerHttpRequestLog(req));
  }

  @override
  void logResponse(HttpApiResponseLog res) {
    if (kDebugMode) _talker.logCustom(_TalkerHttpResponseLog(res.response));
  }

  @override
  void logException(Object error, StackTrace stackTrace) {
    _talker.handle(error, stackTrace, 'TalkerHttpApiLoggerAdapter');
  }
}

/// -----
@Deprecated('Use TalkerHttpApiLoggerAdapter instead.')
class TalkerHttpApiLogger extends TalkerHttpApiLoggerAdapter {
  TalkerHttpApiLogger({super.talker});
}

/// ----

const encoder = JsonEncoder.withIndent('  ');

class _TalkerHttpRequestLog extends TalkerLog {
  _TalkerHttpRequestLog(this.requestLog) : super(requestLog.uri.toString());

  final HttpApiRequestLog requestLog;

  @override
  AnsiPen get pen => (AnsiPen()..xterm(219));

  @override
  String get key => TalkerLogType.httpRequest.key;

  @override
  String generateTextMessage({
    TimeFormat timeFormat = TimeFormat.timeAndSeconds,
  }) {
    var msg = '[$title] [${requestLog.method}] $message';

    try {
      final prettyHeaders = encoder.convert(requestLog.headers);
      msg += '\nHeaders: $prettyHeaders';
      final prettyBody = encoder.convert(requestLog.body);
      msg += '\nBody: $prettyBody';
    } catch (_) {
      msg += '\nError Parse Body: ';
      msg += '\nRaw body: ${requestLog.body}';
    }
    return msg;
  }
}

class _TalkerHttpResponseLog extends TalkerLog {
  _TalkerHttpResponseLog(this.response)
      : super(response.request?.url.toString() ?? 'NO_URL_!!');

  final Response response;

  @override
  AnsiPen get pen => (AnsiPen()..xterm(46));

  @override
  String get title => TalkerLogType.httpResponse.key;

  @override
  String generateTextMessage({
    TimeFormat timeFormat = TimeFormat.timeAndSeconds,
  }) {
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
      msg += '\nError Parse Body: ';
      msg += '\nTry to print raw body: $body';
    }
    return msg;
  }
}
