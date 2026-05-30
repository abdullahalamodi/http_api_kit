import 'package:http_api_kit/http_api_kit.dart';

extension ObjectExceptionExt on Object {
  String logAndGetMessage(StackTrace stackTrace) {
    CustomLogger.logException(this, stackTrace);
    if (this is HttpApiException) return (this as HttpApiException).message;
    return toString();
  }

  HttpApiException logAndGetException(StackTrace stackTrace) {
    CustomLogger.logException(this, stackTrace);
    if (this is HttpApiException) return (this as HttpApiException);
    return UnknownException(toString());
  }
}
