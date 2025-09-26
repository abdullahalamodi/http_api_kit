// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import '../async_widgets_kit.dart';

class PaginationWidget extends StatefulWidget {
  const PaginationWidget({
    super.key,
    required this.pagination,
    required this.onChangePage,
  });
  final PaginationModel pagination;
  final void Function(int page) onChangePage;

  @override
  State<PaginationWidget> createState() => _PaginationWidgetState();
}

class _PaginationWidgetState extends State<PaginationWidget> {
  int _currentPage = 1;

  @override
  void didChangeDependencies() {
    _currentPage = widget.pagination.currentPage;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final pagesList = [
      if (widget.pagination.currentPage > 2) 1,
      if (widget.pagination.previousPage != null)
        widget.pagination.previousPage,
      widget.pagination.currentPage,
      if (widget.pagination.nextPage != null) widget.pagination.nextPage,
      if (widget.pagination.totalPages - 1 > widget.pagination.currentPage)
        widget.pagination.totalPages,
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (var i = 0; i < pagesList.length; i++) ...[
            // befor last page
            if ((i == pagesList.length - 1) &&
                widget.pagination.totalPages - 1 > _currentPage)
              const Text(' ... '),

            InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onTap: () {
                if (pagesList[i] == _currentPage) return;
                _currentPage = pagesList[i]!;
                widget.onChangePage(_currentPage);
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 11,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: pagesList[i] == _currentPage
                      ? Colors.orange[100]
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '${pagesList[i]}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: pagesList[i] == _currentPage
                            ? Colors.orange
                            : Colors.grey,
                      ),
                ),
              ),
            ),

            // after first page
            if (i == 0 && pagesList.length > 2 && _currentPage > 2)
              const Text(' ... '),
          ],
        ],
      ),
    );
  }
}
