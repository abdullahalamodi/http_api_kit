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
      return loadingBuilder.call();
    } else if (asyncData.error != null) {
      return errorBuilder.call(asyncData.error!);
    }

    final child = dataBuilder.call(asyncData.dataModel);
    if (!asyncData.isRefreshing) {
      return child;
    }

    if (refreshingBuilder != null) {
      return refreshingBuilder!(context, child);
    }

    return child;
  }
}
