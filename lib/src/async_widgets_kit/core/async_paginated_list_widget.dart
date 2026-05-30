import 'package:flutter/material.dart';

import '../async_widgets_kit.dart';

class AsyncPaginatedListWidget<T> extends StatelessWidget {
  const AsyncPaginatedListWidget({
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
      loadingBuilder: loadingWidgetBuilder ?? () => const SimpleLoadingWidget(),
      errorBuilder: errorWidgetBuilder ??
          (error) => SimpleErrorWidget(
                error: error,
                onRetry: () => onRetry(),
              ),
      refreshingBuilder: refreshingBuilder,
      dataBuilder: (dataModel) {
        if (dataModel?.data == null || dataModel!.data.isEmpty) {
          if (emptyWidgetBuilder != null) {
            return emptyWidgetBuilder!(context);
          }
          return const SimpleEmptyWidget();
        }
        return Column(
          children: [
            Expanded(
              child: dataBuilder(dataModel.data),
            ),
            PaginationWidget(
              pagination: dataModel.pagination,
              onChangePage: onPageChanged,
            ),
          ],
        );
      },
    );
  }
}
