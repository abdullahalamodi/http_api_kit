abstract class BaseStateModel<T> {
  const BaseStateModel();

  bool get loading;

  bool get innerloading;

  bool get isRefreshing => innerloading;

  String? get error;

  T get dataModel;
}
