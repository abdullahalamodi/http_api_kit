// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../async_widgets_kit.dart';

class PaginatedDataModel<T> {
  PaginatedDataModel({required this.data, required this.pagination});

  final List<T> data;
  final PaginationModel pagination;

  PaginatedDataModel<T> copyWith({
    List<T>? data,
    PaginationModel? pagination,
  }) {
    return PaginatedDataModel<T>(
      data: data ?? this.data,
      pagination: pagination ?? this.pagination,
    );
  }
}
