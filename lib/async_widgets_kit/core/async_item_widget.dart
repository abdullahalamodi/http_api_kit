import 'package:flutter/material.dart';

import '../async_widgets_kit.dart';

class AsyncItemWidget<T> extends StatelessWidget {
  const AsyncItemWidget({
    super.key,
    required this.asyncData,
    required this.dataBuilder,
    required this.onRetry,
  });

  final ItemStateModel<T> asyncData;
  final Widget Function(T? data) dataBuilder;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AsyncWidget(
      asyncData: asyncData,
      loadingBuilder: () {
        return const SimpleLoadingWidget();
      },
      errorBuilder: (error) {
        return SimpleErrorWidget(
          error: error,
          onRetry: () => onRetry(),
        );
      },
      dataBuilder: (data) => dataBuilder(data),
    );
  }
}
