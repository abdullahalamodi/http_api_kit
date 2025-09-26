// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../async_widgets_kit.dart';

class ItemStateModel<T> extends BaseStateModel<T?> {
  @override
  final bool loading;

  @override
  final String? error;

  @override
  final T? dataModel;

  @override
  final bool innerloading;

  ItemStateModel({
    required this.loading,
    required this.error,
    required this.dataModel,
    this.innerloading = false,
  });

  factory ItemStateModel.init() {
    return ItemStateModel(
      loading: true,
      error: null,
      dataModel: null,
      innerloading: false,
    );
  }

  ItemStateModel<T> copyWith({
    bool? loading,
    String? error,
    T? data,
    bool? innerloading,
  }) {
    return ItemStateModel<T>(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      dataModel: data ?? this.dataModel,
      innerloading: innerloading ?? this.innerloading,
    );
  }

  @override
  bool operator ==(covariant ItemStateModel<T> other) {
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
    return 'ItemStateModel(loading: $loading, error: $error, data: $dataModel, innerloading: $innerloading)';
  }
}
