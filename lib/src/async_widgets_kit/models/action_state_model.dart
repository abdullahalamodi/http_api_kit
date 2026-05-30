import '../../http_kit/http_kit.dart';

@Deprecated(
  'Use ActionState<T, A> with an app-owned action enum instead. '
  'ActionStateModel will stay for compatibility.',
)
sealed class ActionStateModel<T> {
  const ActionStateModel();

  const factory ActionStateModel.init() = ActionInitState<T>;

  const factory ActionStateModel.success({
    T? data,
    ActionType action,
  }) = ActionSuccessState<T>;

  const factory ActionStateModel.exception(
    HttpApiException exception,
  ) = ActionErrorState<T>;

  R when<R>({
    required R Function() init,
    required R Function(T? data, ActionType action) success,
    required R Function(HttpApiException exception) error,
  });

  R? whenOrNull<R>({
    R? Function()? init,
    R? Function(T? data, ActionType action)? success,
    R? Function(HttpApiException exception)? error,
  });
}

final class ActionInitState<T> extends ActionStateModel<T> {
  const ActionInitState();

  @override
  R when<R>({
    required R Function() init,
    required R Function(T? data, ActionType action) success,
    required R Function(HttpApiException exception) error,
  }) {
    return init();
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is ActionInitState<T>;
  }

  @override
  R? whenOrNull<R>({
    R? Function()? init,
    R? Function(T? data, ActionType action)? success,
    R? Function(HttpApiException exception)? error,
  }) {
    return init?.call();
  }

  @override
  int get hashCode => T.hashCode;
}

final class ActionSuccessState<T> extends ActionStateModel<T> {
  const ActionSuccessState({
    this.data,
    this.action = ActionType.none,
  });

  final T? data;
  final ActionType action;

  @override
  R when<R>({
    required R Function() init,
    required R Function(T? data, ActionType action) success,
    required R Function(HttpApiException exception) error,
  }) {
    return success(data, action);
  }

  @override
  R? whenOrNull<R>({
    R? Function()? init,
    R? Function(T? data, ActionType action)? success,
    R? Function(HttpApiException exception)? error,
  }) {
    return success?.call(data, action);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ActionSuccessState<T> &&
            other.data == data &&
            other.action == action;
  }

  @override
  int get hashCode => Object.hash(data, action);
}

final class ActionErrorState<T> extends ActionStateModel<T> {
  const ActionErrorState(this.exception);

  final HttpApiException exception;

  @override
  R when<R>({
    required R Function() init,
    required R Function(T? data, ActionType action) success,
    required R Function(HttpApiException exception) error,
  }) {
    return error(exception);
  }

  @override
  R? whenOrNull<R>({
    R? Function()? init,
    R? Function(T? data, ActionType action)? success,
    R? Function(HttpApiException exception)? error,
  }) {
    return error?.call(exception);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ActionErrorState<T> && other.exception == exception;
  }

  @override
  int get hashCode => exception.hashCode;
}

@Deprecated(
  'Use an app-owned enum with ActionState<T, A> instead. '
  'This enum contains app-specific values and is kept for compatibility.',
)
enum ActionType {
  login,
  signup,
  add,
  edit,
  delete,
  download,
  confirm,
  cancel,
  init,
  marked,
  none;

  bool get isAdd => this == add;
  bool get isEdit => this == edit;
  bool get isDelete => this == delete;
}
