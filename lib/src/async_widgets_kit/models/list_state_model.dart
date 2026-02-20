// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../async_widgets_kit.dart';

class ListStateModel<T> extends BaseStateModel<PaginatedDataModel<T>?> {
  @override
  final bool loading;

  @override
  final String? error;

  @override
  final PaginatedDataModel<T>? dataModel;

  @override
  final bool innerloading;

  ListStateModel({
    required this.loading,
    required this.error,
    required this.dataModel,
    required this.innerloading,
  });

  factory ListStateModel.init() {
    return ListStateModel(
      loading: true,
      error: null,
      dataModel: null,
      innerloading: false,
    );
  }

  @override
  bool operator ==(covariant ListStateModel<T> other) {
    if (identical(this, other)) return true;

    return other.loading == loading &&
        other.error == error &&
        other.dataModel == dataModel &&
        other.innerloading == innerloading;
  }

  @override
  int get hashCode {
    return loading.hashCode ^
        error.hashCode ^
        dataModel.hashCode ^
        innerloading.hashCode;
  }

  @override
  String toString() {
    return 'ListStateModel(loading: $loading, error: $error, dataModel: $dataModel, innerloading: $innerloading)';
  }

  ListStateModel<T> copyWith({
    bool? loading,
    Object? error = sentinel,
    Object? dataModel = sentinel,
    bool? innerloading,
  }) {
    return ListStateModel<T>(
      loading: loading ?? this.loading,
      error: isUndefined(error) ? this.error : error as String?,
      dataModel: isUndefined(dataModel)
          ? this.dataModel
          : dataModel as PaginatedDataModel<T>?,
      innerloading: innerloading ?? this.innerloading,
    );
  }
}
