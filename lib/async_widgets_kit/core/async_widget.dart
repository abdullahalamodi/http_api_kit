import 'package:flutter/material.dart';
import 'package:http_api_kit/async_widgets_kit/async_widgets_kit.dart';

class AsyncWidget<T> extends StatelessWidget {
  const AsyncWidget({
    super.key,
    required this.asyncData,
    required this.dataBuilder,
    required this.loadingBuilder,
    required this.emptyBuilder,
    required this.errorBuilder,
  });

  final BaseStateModel<T> asyncData;
  final Widget Function(T data) dataBuilder;
  final Widget Function() loadingBuilder;
  final Widget Function() emptyBuilder;
  final Widget Function(String error) errorBuilder;

  @override
  Widget build(BuildContext context) {
    if (asyncData.loading) {
      return loadingBuilder.call();
    } else if (asyncData.error != null) {
      return errorBuilder.call(asyncData.error!);
    } else {
      if (asyncData.dataModel != null) {
        return dataBuilder.call(asyncData.dataModel);
      } else {
        return emptyBuilder.call();
      }
    }
  }
}
