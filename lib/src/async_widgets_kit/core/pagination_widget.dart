// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../async_widgets_kit.dart';

class PaginationWidget extends StatelessWidget {
  const PaginationWidget({
    super.key,
    required this.pagination,
    required this.onChangePage,
  });

  final PaginationModel pagination;
  final void Function(int page) onChangePage;

  @override
  Widget build(BuildContext context) {
    final currentPage = pagination.currentPage;
    final pagesList = [
      if (currentPage > 2) 1,
      if (pagination.previousPage != null) pagination.previousPage,
      currentPage,
      if (pagination.nextPage != null) pagination.nextPage,
      if (pagination.totalPages - 1 > currentPage) pagination.totalPages,
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (var i = 0; i < pagesList.length; i++) ...[
            if ((i == pagesList.length - 1) &&
                pagination.totalPages - 1 > currentPage)
              const Text(' ... '),
            InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onTap: () {
                final page = pagesList[i]!;
                if (page == currentPage) return;
                onChangePage(page);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 11,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: pagesList[i] == currentPage
                      ? Colors.orange[100]
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '${pagesList[i]}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: pagesList[i] == currentPage
                            ? Colors.orange
                            : Colors.grey,
                      ),
                ),
              ),
            ),
            if (i == 0 && pagesList.length > 2 && currentPage > 2)
              const Text(' ... '),
          ],
        ],
      ),
    );
  }
}
