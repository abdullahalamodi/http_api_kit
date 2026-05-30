import 'package:http_api_kit/src/http_api/core/custom_logger.dart';
import 'package:http_api_kit/src/http_api/exceptions/http_api_exception.dart';

extension ObjectExceptionExt on Object {
  String logAndGetMessage(StackTrace stackTrace) {
    CustomLogger.logException(this, stackTrace);
    if (this is HttpApiException) return (this as HttpApiException).message;
    return toString();
  }
}
