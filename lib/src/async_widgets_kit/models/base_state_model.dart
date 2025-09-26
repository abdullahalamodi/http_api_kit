abstract class BaseStateModel<T> {
  const BaseStateModel();
  abstract final bool loading;
  abstract final bool innerloading;
  abstract final String? error;
  abstract final T dataModel;
}
