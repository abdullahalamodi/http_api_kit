// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:http_api_kit/async_widgets_kit/async_widgets_kit.dart';

class AsyncListWidget<T> extends StatelessWidget {
  const AsyncListWidget({
    super.key,
    required this.asyncData,
    required this.onRetry,
    required this.onPageChanged,
    required this.dataBuilder,
  });

  final BaseStateModel<PaginatedDataModel<T>?> asyncData;
  final VoidCallback onRetry;
  final void Function(int page)? onPageChanged;
  final Widget Function(List<T> data) dataBuilder;

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
        emptyBuilder: () {
          return const SimpleEmptyWidget();
        },
        dataBuilder: (dataModel) {
          return Column(
            children: [
              dataBuilder(dataModel!.data),
              if (onPageChanged != null)
                PaginationWidget(
                  pagination: dataModel.pagination,
                  onChangePage: onPageChanged!,
                ),
            ],
          );
        });
  }
}
