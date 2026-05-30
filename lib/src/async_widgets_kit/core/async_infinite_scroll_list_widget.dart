import 'package:flutter/material.dart';

import '../async_widgets_kit.dart';

class AsyncInfiniteScrollListWidget<T> extends StatefulWidget {
  const AsyncInfiniteScrollListWidget({
    super.key,
    required this.asyncData,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.onRetry,
    this.hasMore,
    this.emptyWidgetBuilder,
    this.loadingWidgetBuilder,
    this.errorWidgetBuilder,
    this.loadingMoreWidgetBuilder,
    this.refreshingBuilder,
    this.loadMoreThreshold = 200,
  });

  final BaseStateModel<PaginatedDataModel<T>?> asyncData;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final void Function(int page) onLoadMore;
  final VoidCallback onRetry;
  final bool Function(PaginationModel pagination)? hasMore;
  final Widget Function(BuildContext context)? emptyWidgetBuilder;
  final Widget Function()? loadingWidgetBuilder;
  final Widget Function(String error)? errorWidgetBuilder;
  final Widget Function()? loadingMoreWidgetBuilder;
  final Widget Function(BuildContext context, Widget child)? refreshingBuilder;
  final double loadMoreThreshold;

  @override
  State<AsyncInfiniteScrollListWidget<T>> createState() =>
      _AsyncInfiniteScrollListWidgetState<T>();
}

class _AsyncInfiniteScrollListWidgetState<T>
    extends State<AsyncInfiniteScrollListWidget<T>> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  bool _hasMore(PaginationModel pagination) {
    return widget.hasMore?.call(pagination) ?? pagination.nextPage != null;
  }

  void _onScroll() {
    if (widget.asyncData.innerloading) return;

    final pagination = widget.asyncData.dataModel?.pagination;
    if (pagination == null) return;

    final position = _scrollController.position;
    if (position.pixels >=
        position.maxScrollExtent - widget.loadMoreThreshold) {
      if (_hasMore(pagination)) {
        widget.onLoadMore(pagination.nextPage!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.asyncData.loading) {
      return (widget.loadingWidgetBuilder ?? () => const SimpleLoadingWidget())
          .call();
    }

    if (widget.asyncData.error != null && !widget.asyncData.innerloading) {
      return (widget.errorWidgetBuilder ??
              (error) => SimpleErrorWidget(
                    error: error,
                    onRetry: () => widget.onRetry(),
                  ))
          .call(widget.asyncData.error!);
    }

    final data = widget.asyncData.dataModel?.data ?? [];
    final child = data.isEmpty
        ? (widget.emptyWidgetBuilder?.call(context) ??
            const SimpleEmptyWidget())
        : _buildListView(data);

    if (widget.asyncData.innerloading && widget.refreshingBuilder != null) {
      return widget.refreshingBuilder!(context, child);
    }

    return child;
  }

  Widget _buildListView(List<T> data) {
    final pagination = widget.asyncData.dataModel?.pagination;
    final more = pagination != null && _hasMore(pagination);

    return ListView.builder(
      controller: _scrollController,
      itemCount: data.length + (more ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < data.length) {
          return widget.itemBuilder(context, data[index]);
        }
        return (widget.loadingMoreWidgetBuilder ??
                () => const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ))
            .call();
      },
    );
  }
}
