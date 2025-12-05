import 'package:flutter/material.dart';

import '../async_widgets_kit.dart';

class AsyncWidget<T> extends StatelessWidget {
  const AsyncWidget({
    super.key,
    required this.asyncData,
    required this.dataBuilder,
    required this.loadingBuilder,
    required this.errorBuilder,
  });

  final BaseStateModel<T> asyncData;
  final Widget Function(T data) dataBuilder;
  final Widget Function() loadingBuilder;
  final Widget Function(String error) errorBuilder;

  @override
  Widget build(BuildContext context) {
    if (asyncData.loading) {
      return loadingBuilder.call();
    } else if (asyncData.error != null) {
      return errorBuilder.call(asyncData.error!);
    } else {
      return dataBuilder.call(asyncData.dataModel);
    }
  }
}
