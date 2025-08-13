import '../async_widgets_kit.dart';

class PaginatedDataModel<T> {
  PaginatedDataModel({required this.data, required this.pagination});

  final List<T> data;
  final PaginationModel pagination;
}
