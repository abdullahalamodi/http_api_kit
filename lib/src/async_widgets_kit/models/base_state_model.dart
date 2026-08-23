import 'package:http_api_kit/http_api_kit.dart';

abstract class BaseStateModel<T> {
  const BaseStateModel();

  bool get loading;

  bool get innerloading;

  bool get isRefreshing => innerloading;

  HttpApiException? get error;

  T get dataModel;
}
