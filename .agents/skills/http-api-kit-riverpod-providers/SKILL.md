# http_api_kit Riverpod Providers

Use this skill when creating Riverpod providers that consume repositories built on `http_api_kit` and expose `ItemStateModel<T>`, `ListStateModel<T>`, or action state to Flutter views.

## Goal

Providers should own async flow, loading flags, errors, pagination, refresh behavior, and interaction with repositories. Repositories return typed data. Widgets render state.

Preferred imports:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http_api_kit/http_api_kit.dart';
```

Use `legacy.dart` only when using `StateNotifierProvider` and `StateNotifier`.

## Item Provider Pattern

Use `ItemStateModel<T>` for one object or lookup result.

```dart
typedef _MainState = ItemStateModel<AttendanceResultModel>;

final showScanResultProvider = StateNotifierProvider.autoDispose
    .family<ShowScanResultProvider, _MainState, ScanFamily>(
  (ref, scanFamily) {
    return ShowScanResultProvider(ref, scanFamily);
  },
);

class ShowScanResultProvider extends StateNotifier<_MainState> {
  ShowScanResultProvider(this.ref, this.scanFamily)
      : super(ItemStateModel.init()) {
    lookup();
  }

  final Ref ref;
  final ScanFamily scanFamily;

  Future<void> lookup() async {
    state = state.copyWith(
      loading: state.dataModel == null,
      innerloading: state.dataModel != null,
      error: null,
    );

    try {
      final data = await ref
          .read(activitiesRepoProvider)
          .scanReservation(scanFamily);

      state = state.copyWith(
        loading: false,
        innerloading: false,
        error: null,
        data: data,
      );
    } catch (e, s) {
      CustomLogger.exceptionLogger(error: e, stackTrace: s);
      final message = e is HttpApiException ? e.message : e.toString();

      state = state.copyWith(
        loading: false,
        innerloading: false,
        error: message,
        data: null,
      );
    }
  }
}
```

Tips:

- Use `loading` for first blocking load.
- Use `innerloading` for refresh-in-place when existing data should stay visible.
- Keep the family argument immutable and comparable.
- In `autoDispose.family`, call `ref.invalidate(provider(arg))` from UI to retry with a fresh notifier.

Warnings:

- Do not set `loading: true` when refreshing existing data, or the widget will replace data with the loading UI.
- Do not ignore `StackTrace`; log it at provider boundary.
- Do not call `ref.watch` inside provider methods. Use `ref.read` for one-shot repository calls.
- Do not trigger navigation or snackbars from data providers.

## List Provider Pattern

Use `ListStateModel<T>` when repository returns `PaginatedDataModel<T>`.

```dart
typedef _MainState = ListStateModel<ActivityModel>;

final listActivitiesProvider = StateNotifierProvider.autoDispose
    .family<ListActivitiesProvider, _MainState, ActivityType>(
  (ref, type) {
    return ListActivitiesProvider(ref, type);
  },
);

class ListActivitiesProvider extends StateNotifier<_MainState> {
  ListActivitiesProvider(this.ref, this.type)
      : super(ListStateModel.init()) {
    getActivities();
  }

  final Ref ref;
  final ActivityType type;

  Future<void> getActivities({
    FilterModel filters = const FilterModel(),
    int page = 1,
    bool skipLoading = false,
  }) async {
    final hasData = state.dataModel != null;

    if (!skipLoading) {
      state = state.copyWith(
        loading: !hasData,
        innerloading: hasData,
        error: null,
      );
    }

    try {
      final data = await ref.read(activitiesRepoProvider).getActivities(
            filters: filters.copyWith(page: page),
            type: type,
          );

      state = state.copyWith(
        loading: false,
        innerloading: false,
        dataModel: data,
        error: null,
      );
    } catch (e, s) {
      CustomLogger.exceptionLogger(error: e, stackTrace: s);
      final message = e is HttpApiException ? e.message : e.toString();

      state = state.copyWith(
        loading: false,
        innerloading: false,
        dataModel: hasData ? state.dataModel : null,
        error: message,
      );
    }
  }

  bool get noMore {
    final pagination = state.dataModel?.pagination;
    return pagination == null ||
        pagination.totalPages == 0 ||
        pagination.currentPage == pagination.totalPages;
  }

  Future<bool> onLoadingMore() async {
    final current = state.dataModel;
    if (current == null || noMore) return false;

    try {
      final nextPage = current.pagination.currentPage + 1;
      final nextData = await ref.read(activitiesRepoProvider).getActivities(
            filters: FilterModel(page: nextPage),
            type: type,
          );

      state = state.copyWith(
        dataModel: PaginatedDataModel<ActivityModel>(
          data: [
            ...current.data,
            ...nextData.data,
          ],
          pagination: nextData.pagination,
        ),
        loading: false,
        innerloading: false,
        error: null,
      );

      return true;
    } catch (e, s) {
      CustomLogger.exceptionLogger(error: e, stackTrace: s);
      return false;
    }
  }
}
```

Tips:

- For "load more", append to the existing list instead of replacing it.
- For filter changes, replace the list and reset the page to `1`.
- For pull-to-refresh, keep existing data visible and set `innerloading: true`.
- Keep `noMore` derived from state instead of storing another mutable flag.

Warnings:

- Do not call `state.dataModel!` unless the method already checked for null.
- Do not replace data with null on a refresh error unless the initial load failed.
- Do not mix pagination state into the widget. The provider should decide what page to load.

## Filtered List Pattern

When filters change, pass a full immutable filter object.

```dart
Future<void> applyFilters(FilterModel filters) {
  return getActivities(
    filters: filters.copyWith(page: 1),
    page: 1,
  );
}
```

For custom filters:

```dart
final filters = const FilterModel().copyWith(
  page: 1,
  customFilters: {
    'filters[status]': 'confirmed',
    'filters[date_from]': dateFrom,
    'filters[date_to]': dateTo,
  },
);

await ref
    .read(listActivitiesProvider(ActivityType.events).notifier)
    .getActivities(filters: filters);
```

## Refresh-In-Place Pattern

Use `innerloading` when data exists and the UI should remain visible.

```dart
Future<void> refresh() async {
  final current = state.dataModel;

  state = state.copyWith(
    loading: current == null,
    innerloading: current != null,
    error: null,
  );

  try {
    final data = await ref.read(activitiesRepoProvider).getActivities(
          filters: const FilterModel(page: 1),
          type: type,
        );

    state = state.copyWith(
      loading: false,
      innerloading: false,
      dataModel: data,
      error: null,
    );
  } catch (e, s) {
    CustomLogger.exceptionLogger(error: e, stackTrace: s);
    final message = e is HttpApiException ? e.message : e.toString();

    state = state.copyWith(
      loading: false,
      innerloading: false,
      dataModel: current,
      error: current == null ? message : null,
    );
  }
}
```

## Provider Invalidation And Retry

For family providers:

```dart
final provider = showActivityProvider((
  id: activityId,
  type: activityType,
));

AsyncItemWidget(
  asyncData: ref.watch(provider),
  onRetry: () => ref.invalidate(provider),
  dataBuilder: (data) => ActivityDetailsView(data!),
);
```

For non-family providers:

```dart
AsyncItemWidget(
  asyncData: ref.watch(profileProvider),
  onRetry: () => ref.invalidate(profileProvider),
  dataBuilder: (profile) => ProfileView(profile!),
);
```

## Documentation Links

- Riverpod providers: https://riverpod.dev/docs/concepts2/providers
- Riverpod auto dispose: https://riverpod.dev/docs/concepts2/auto_dispose
- Riverpod families: https://riverpod.dev/docs/concepts2/family
- Riverpod `ref.listen`: https://riverpod.dev/docs/concepts2/refs
- Flutter async UI cookbook: https://docs.flutter.dev/cookbook/networking/fetch-data
