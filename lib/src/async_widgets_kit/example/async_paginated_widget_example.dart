import 'package:flutter/widgets.dart';

import '../async_widgets_kit.dart';

class AsyncPaginatedWidgetExample extends StatelessWidget {
  const AsyncPaginatedWidgetExample({super.key});

  // you can chagne the state form here by edit data
  PaginatedStateModel<String> _data() {
    return PaginatedStateModel(
      loading: false,
      error: 'error',
      dataModel: PaginatedDataModel(
        data: [],
        pagination: PaginationModel(
          currentPage: 1,
          perPage: 1,
          nextPage: null,
          previousPage: null,
          totalEntries: 1,
          totalPages: 1,
        ),
      ),
      innerloading: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AsyncPaginatedWidget(
          asyncData: _data(),
          onRetry: () {
            // on error add refresh
          },
          onPageChanged: (p) {
            // for paginaton
          },
          dataBuilder: (data) {
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return Text(data[index]);
              },
            );
          },
        ),
      ],
    );
  }
}
