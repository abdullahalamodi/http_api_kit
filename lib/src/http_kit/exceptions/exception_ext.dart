import 'package:http_api_kit/http_api_kit.dart';

extension ObjectExceptionExt on Object {
  HttpApiException get getException {
    if (this is HttpApiException) return (this as HttpApiException);
    return UnknownException(toString());
  }

  String get getMessage {
    return getException.message;
  }

  String logAndGetMessage(StackTrace stackTrace) {
    CustomLogger.logException(this, stackTrace);
    return getMessage;
  }

  HttpApiException logAndGetException(StackTrace stackTrace) {
    CustomLogger.logException(this, stackTrace);
    return getException;
  }
}
