import 'package:flutter/material.dart';

import '../async_widgets_kit.dart';

class AsyncPaginatedWidget<T> extends StatelessWidget {
  const AsyncPaginatedWidget({
    super.key,
    required this.asyncData,
    required this.onRetry,
    required this.dataBuilder,
    required this.onPageChanged,
    this.emptyWidgetBuilder,
    this.loadingWidgetBuilder,
    this.errorWidgetBuilder,
    this.refreshingBuilder,
  });

  final BaseStateModel<PaginatedDataModel<T>?> asyncData;
  final VoidCallback onRetry;
  final Widget Function(List<T> data) dataBuilder;
  final void Function(int page) onPageChanged;
  final Widget Function(BuildContext context)? emptyWidgetBuilder;
  final Widget Function()? loadingWidgetBuilder;
  final Widget Function(String error)? errorWidgetBuilder;
  final Widget Function(BuildContext context, Widget child)? refreshingBuilder;

  @override
  Widget build(BuildContext context) {
    return AsyncWidget(
      asyncData: asyncData,
      loadingBuilder: _buildLoadingWidget,
      errorBuilder: _buildErrorWidget,
      refreshingBuilder: _buildRefreshingWidget,
      dataBuilder: (dataModel) => _buildDataWidget(context, dataModel),
    );
  }

  Widget _buildLoadingWidget() =>
      (loadingWidgetBuilder ?? () => const SimpleLoadingWidget()).call();

  Widget _buildErrorWidget(String error) => (errorWidgetBuilder ??
          (e) => SimpleErrorWidget(
                error: e,
                onRetry: () => onRetry(),
              ))
      .call(error);

  Widget _buildDataWidget(
      BuildContext context, PaginatedDataModel<T>? dataModel) {
    if (dataModel?.data == null || dataModel!.data.isEmpty) {
      return emptyWidgetBuilder?.call(context) ?? const SimpleEmptyWidget();
    }
    return Column(
      children: [
        dataBuilder(dataModel.data),
        PaginationWidget(
          pagination: dataModel.pagination,
          onChangePage: onPageChanged,
        ),
      ],
    );
  }

  Widget _buildRefreshingWidget(BuildContext context, Widget child) =>
      refreshingBuilder?.call(context, child) ??
      SimpleRefreshWidget(
        isRefreshing: asyncData.isRefreshing,
        child: child,
      );
}
