import '../../http_kit/http_kit.dart';

enum SimpleAction { action }

typedef CommandState<T> = ActionState<T, SimpleAction>;
typedef ActionSuccessBuilder<T, A extends Object, R> = R Function(
  T? data,
  A? action,
);

typedef ActionFailureBuilder<A extends Object, R> = R Function(
  HttpApiException exception,
  A? action,
);

class ActionState<T, A extends Object> {
  const ActionState._();

  const factory ActionState.init() = ActionInit<T, A>;

  const factory ActionState.success({
    T? data,
    A? action,
  }) = ActionSuccess<T, A>;

  const factory ActionState.failure(
    HttpApiException exception, {
    A? action,
  }) = ActionFailure<T, A>;

  @Deprecated('Use ActionState.failure instead.')
  const factory ActionState.exception(
    HttpApiException exception, {
    A? action,
  }) = ActionFailure<T, A>;

  R when<R>({
    required R Function() init,
    required ActionSuccessBuilder<T, A, R> success,
    required ActionFailureBuilder<A, R> failure,
  }) {
    final state = this;

    if (state is ActionInit<T, A>) {
      return init();
    }

    if (state is ActionSuccess<T, A>) {
      return success(state.data, state.action);
    }

    if (state is ActionFailure<T, A>) {
      return failure(state.exception, state.action);
    }

    throw StateError('Unsupported action state: $state');
  }

  R? whenOrNull<R>({
    R? Function()? init,
    ActionSuccessBuilder<T, A, R?>? success,
    ActionFailureBuilder<A, R?>? failure,
  }) {
    final state = this;

    if (state is ActionInit<T, A>) {
      return init?.call();
    }

    if (state is ActionSuccess<T, A>) {
      return success?.call(state.data, state.action);
    }

    if (state is ActionFailure<T, A>) {
      return failure?.call(state.exception, state.action);
    }

    return null;
  }
}

final class ActionInit<T, A extends Object> extends ActionState<T, A> {
  const ActionInit() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is ActionInit<T, A>;
  }

  @override
  int get hashCode => Object.hash(T, A);
}

final class ActionSuccess<T, A extends Object> extends ActionState<T, A> {
  const ActionSuccess({
    this.data,
    this.action,
  }) : super._();

  final T? data;
  final A? action;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ActionSuccess<T, A> &&
            other.data == data &&
            other.action == action;
  }

  @override
  int get hashCode => Object.hash(data, action);
}

final class ActionFailure<T, A extends Object> extends ActionState<T, A> {
  const ActionFailure(
    this.exception, {
    this.action,
  }) : super._();

  final HttpApiException exception;
  final A? action;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ActionFailure<T, A> &&
            other.exception == exception &&
            other.action == action;
  }

  @override
  int get hashCode => Object.hash(exception, action);
}
