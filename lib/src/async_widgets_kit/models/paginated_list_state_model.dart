// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:http_api_kit/http_api_kit.dart';

class PaginatedStateModel<T> extends BaseStateModel<PaginatedDataModel<T>?> {
  @override
  final bool loading;

  @override
  final HttpApiException? error;

  @override
  final PaginatedDataModel<T>? dataModel;

  @override
  final bool innerloading;

  @override
  bool get isRefreshing => innerloading;

  PaginatedStateModel({
    required this.loading,
    required this.error,
    required this.dataModel,
    required this.innerloading,
  });

  factory PaginatedStateModel.init() {
    return PaginatedStateModel(
      loading: true,
      error: null,
      dataModel: null,
      innerloading: false,
    );
  }

  PaginatedStateModel<T> withLoading() {
    return copyWith(
        loading: true, error: null, dataModel: null, innerloading: false);
  }

  PaginatedStateModel<T> withInnerLoading() {
    if (dataModel == null) return this;
    return copyWith(
      innerloading: true,
      loading: false,
      error: null,
      dataModel: null,
    );
  }

  PaginatedStateModel<T> withData(PaginatedDataModel<T> dataModel) {
    return copyWith(
      loading: false,
      error: null,
      dataModel: dataModel,
      innerloading: false,
    );
  }

  PaginatedStateModel<T> appendData(PaginatedDataModel<T> newDataModel) {
    return copyWith(
      loading: false,
      error: null,
      dataModel: PaginatedDataModel(
        data: newDataModel.pagination.currentPage == 1
            ? newDataModel.data
            : [...?dataModel?.data, ...newDataModel.data],
        pagination: newDataModel.pagination,
      ),
      innerloading: false,
    );
  }

  PaginatedStateModel<T> withError(
    HttpApiException error, {
    PaginatedDataModel<T>? data,
  }) {
    return copyWith(
        loading: false, error: error, dataModel: data, innerloading: false);
  }

  @override
  bool operator ==(covariant PaginatedStateModel<T> other) {
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
    return 'PaginatedStateModel(loading: $loading, error: $error, dataModel: $dataModel, innerloading: $innerloading)';
  }

  PaginatedStateModel<T> copyWith({
    bool? loading,
    HttpApiException? error,
    PaginatedDataModel<T>? dataModel,
    bool? innerloading,
  }) {
    return PaginatedStateModel<T>(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      dataModel: dataModel ?? this.dataModel,
      innerloading: innerloading ?? this.innerloading,
    );
  }
}
