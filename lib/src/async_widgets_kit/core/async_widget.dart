import 'package:flutter/material.dart';

import '../async_widgets_kit.dart';

class AsyncWidget<T> extends StatelessWidget {
  const AsyncWidget({
    super.key,
    required this.asyncData,
    required this.dataBuilder,
    required this.loadingBuilder,
    required this.errorBuilder,
    this.refreshingBuilder,
  });

  final BaseStateModel<T> asyncData;
  final Widget Function(T data) dataBuilder;
  final Widget Function() loadingBuilder;
  final Widget Function(String error) errorBuilder;
  final Widget Function(BuildContext context, Widget child)? refreshingBuilder;

  @override
  Widget build(BuildContext context) {
    if (asyncData.loading) {
      return _buildLoadingWidget();
    } else if (asyncData.error != null) {
      return _buildErrorWidget(asyncData.error!);
    }

    final child = _buildDataWidget();
    if (asyncData.isRefreshing) {
      return _buildRefreshingWidget(context, child);
    }

    return child;
  }

  Widget _buildLoadingWidget() => loadingBuilder.call();

  Widget _buildErrorWidget(String error) => errorBuilder.call(error);

  Widget _buildDataWidget() => dataBuilder.call(asyncData.dataModel);

  Widget _buildRefreshingWidget(BuildContext context, Widget child) =>
      refreshingBuilder?.call(context, child) ?? child;
}
