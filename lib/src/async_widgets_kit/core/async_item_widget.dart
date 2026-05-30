import 'package:flutter/material.dart';

import '../async_widgets_kit.dart';

class AsyncItemWidget<T> extends StatelessWidget {
  const AsyncItemWidget({
    super.key,
    required this.asyncData,
    required this.dataBuilder,
    required this.onRetry,
    this.emptyWidgetBuilder,
    this.loadingWidgetBuilder,
    this.errorWidgetBuilder,
    this.refreshingBuilder,
  });

  final ItemStateModel<T> asyncData;
  final VoidCallback onRetry;
  final Widget Function(BuildContext context)? emptyWidgetBuilder;
  final Widget Function(T? data) dataBuilder;
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

  Widget _buildDataWidget(BuildContext context, T? data) {
    if (data == null) {
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
