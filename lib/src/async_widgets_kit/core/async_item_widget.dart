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
  });

  final ItemStateModel<T> asyncData;
  final VoidCallback onRetry;
  final Widget Function(BuildContext context)? emptyWidgetBuilder;
  final Widget Function(T? data) dataBuilder;
  final Widget Function()? loadingWidgetBuilder;
  final Widget Function(String error)? errorWidgetBuilder;

  @override
  Widget build(BuildContext context) {
    return AsyncWidget(
      asyncData: asyncData,
      loadingBuilder: loadingWidgetBuilder ?? () => const SimpleLoadingWidget(),
      errorBuilder: errorWidgetBuilder ??
          (error) => SimpleErrorWidget(
                error: error,
                onRetry: () => onRetry(),
              ),
      dataBuilder: (data) {
        if (data == null) {
          if (emptyWidgetBuilder != null) {
            return emptyWidgetBuilder!(context);
          }
          return const SimpleEmptyWidget();
        }
        return dataBuilder(data);
      },
    );
  }
}
