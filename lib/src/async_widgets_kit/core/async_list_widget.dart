import 'package:flutter/material.dart';

import '../async_widgets_kit.dart';

class AsyncListWidget<T> extends StatelessWidget {
  const AsyncListWidget({
    super.key,
    required this.asyncData,
    required this.onRetry,
    required this.dataBuilder,
    this.emptyWidgetBuilder,
    this.loadingWidgetBuilder,
    this.errorWidgetBuilder,
    this.refreshingBuilder,
  });

  final BaseStateModel<List<T>?> asyncData;
  final VoidCallback onRetry;
  final Widget Function(List<T> data) dataBuilder;
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
      dataBuilder: (data) => _buildDataWidget(context, data),
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

  Widget _buildDataWidget(BuildContext context, List<T>? data) {
    if (data == null || data.isEmpty) {
      return emptyWidgetBuilder?.call(context) ?? const SimpleEmptyWidget();
    }
    return dataBuilder(data);
  }

  Widget _buildRefreshingWidget(BuildContext context, Widget child) =>
      refreshingBuilder?.call(context, child) ??
      SimpleRefreshWidget(
        isRefreshing: asyncData.isRefreshing,
        child: child,
      );
}
