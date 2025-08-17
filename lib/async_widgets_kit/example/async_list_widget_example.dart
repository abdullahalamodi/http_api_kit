import 'package:flutter/widgets.dart';

import '../async_widgets_kit.dart';

class AsyncListWidgetExample extends StatelessWidget {
  const AsyncListWidgetExample({super.key});

  // you can chagne the state form here by edit data
  ListStateModel<String> _data() {
    return ListStateModel(
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
        AsyncListWidget(
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
