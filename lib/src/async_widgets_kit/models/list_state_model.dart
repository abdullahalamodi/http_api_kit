// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:http_api_kit/http_api_kit.dart';

class ListStateModel<T> extends BaseStateModel<List<T>?> {
  @override
  final bool loading;

  @override
  final HttpApiException? error;

  @override
  final List<T>? dataModel;

  @override
  final bool innerloading;

  @override
  bool get isRefreshing => innerloading;

  ListStateModel({
    required this.loading,
    required this.error,
    required this.dataModel,
    this.innerloading = false,
  });

  factory ListStateModel.init() {
    return ListStateModel(
      loading: true,
      error: null,
      dataModel: null,
    );
  }

  ListStateModel<T> withLoading() {
    return copyWith(
        loading: true, error: null, dataModel: null, innerloading: false);
  }

  ListStateModel<T> withInnerLoading() {
    if (dataModel == null) return this;
    return copyWith(
      innerloading: true,
      loading: false,
      error: null,
      dataModel: null,
    );
  }

  ListStateModel<T> withData(List<T> data) {
    return copyWith(
      loading: false,
      error: null,
      dataModel: data,
      innerloading: false,
    );
  }

  ListStateModel<T> withError(
    HttpApiException error, {
    List<T>? data,
  }) {
    return copyWith(
        loading: false, error: error, dataModel: data, innerloading: false);
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
    HttpApiException? error,
    List<T>? dataModel,
    bool? innerloading,
  }) {
    return ListStateModel<T>(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      dataModel: dataModel ?? this.dataModel,
      innerloading: innerloading ?? this.innerloading,
    );
  }
}
