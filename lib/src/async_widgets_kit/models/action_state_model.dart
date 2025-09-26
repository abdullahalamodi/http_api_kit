// ignore_for_file: library_private_types_in_public_api

import '../../http_api/http_api.dart';

abstract interface class ActionStateModel<T> {
  ActionStateModel();

  static init() => _Init();
  static success<T>({T? data, ActionType action = ActionType.none}) =>
      _Success<T>(data: data, action: action);
  static exception(HttpApiException exception) => _Error(exception: exception);

  R when<R>({
    required R Function() init,
    required R Function(T? data, ActionType action) success,
    required R Function(HttpApiException exception) error,
  }) {
    throw UnimplementedError(
        'ActionStateModel/when: this method not implemented !');
  }
}

class _Init<T> implements ActionStateModel<T> {
  _Init();

  @override
  R when<R>({
    required R Function() init,
    required R Function(T? data, ActionType action) success,
    required R Function(HttpApiException exception) error,
  }) {
    return init();
  }
}

class _Success<T> implements ActionStateModel<T> {
  final T? data;
  final ActionType action;

  _Success({
    this.data,
    this.action = ActionType.none,
  });

  @override
  R when<R>({
    required R Function() init,
    required R Function(T? data, ActionType action) success,
    required R Function(HttpApiException exception) error,
  }) {
    return success(data, action);
  }
}

class _Error<T> extends ActionStateModel<T> {
  final HttpApiException exception;

  _Error({required this.exception});

  @override
  R when<R>({
    required R Function() init,
    required R Function(T? data, ActionType action) success,
    required R Function(HttpApiException exception) error,
  }) {
    return error(exception);
  }
}

enum ActionType {
  login,
  signup,
  add,
  edit,
  delete,
  download,
  none;

  bool get isAdd => this == add;
  bool get isEdit => this == edit;
  bool get isDelete => this == delete;
}
