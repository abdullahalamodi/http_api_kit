// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../async_widgets_kit.dart';

class AsyncListWidget<T> extends StatelessWidget {
  const AsyncListWidget({
    super.key,
    required this.asyncData,
    required this.onRetry,
    required this.onPageChanged,
    required this.dataBuilder,
    this.emptyWidgetBuilder,
  });

  final BaseStateModel<PaginatedDataModel<T>?> asyncData;
  final VoidCallback onRetry;
  final void Function(int page)? onPageChanged;
  final Widget Function(List<T> data) dataBuilder;
  final Widget Function(BuildContext context)? emptyWidgetBuilder;

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
        dataBuilder: (dataModel) {
          if (dataModel?.data == null || dataModel!.data.isEmpty) {
            if (emptyWidgetBuilder != null) {
              return emptyWidgetBuilder!(context);
            }
            return const SimpleEmptyWidget();
          }

          return Column(
            children: [
              dataBuilder(dataModel.data),
              PaginationWidget(
                pagination: dataModel.pagination,
                onChangePage: onPageChanged!,
              ),
            ],
          );
        });
  }
}
