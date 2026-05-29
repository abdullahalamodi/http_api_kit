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
    final window = pagination.window;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (var i = 0; i < window.pages.length; i++) ...[
            if (i == window.pages.length - 1 && window.hasTrailingGap)
              const Text(' ... '),
            InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onTap: () {
                final page = window.pages[i];
                if (page == window.currentPage) return;
                onChangePage(page);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 11,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: window.pages[i] == window.currentPage
                      ? Colors.orange[100]
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '${window.pages[i]}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: window.pages[i] == window.currentPage
                            ? Colors.orange
                            : Colors.grey,
                      ),
                ),
              ),
            ),
            if (i == 0 && window.hasLeadingGap) const Text(' ... '),
          ],
        ],
      ),
    );
  }
}
