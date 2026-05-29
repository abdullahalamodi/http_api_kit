# http_api_kit Async Widgets

Use this skill when building Flutter UI with `AsyncWidget`, `AsyncItemWidget`, `AsyncListWidget`, `PaginationWidget`, `ItemStateModel`, and `ListStateModel`.

## Goal

Widgets should render state. They should not call repositories directly, parse JSON, or own pagination business rules.

Preferred import:

```dart
import 'package:http_api_kit/http_api_kit.dart';
```

## AsyncItemWidget

Use `AsyncItemWidget<T>` when the screen displays one nullable item.

```dart
class ActivityDetailsPage extends ConsumerWidget {
  const ActivityDetailsPage({
    super.key,
    required this.activityId,
    required this.activityType,
  });

  final String activityId;
  final ActivityType activityType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = showActivityProvider((
      id: activityId,
      type: activityType,
    ));

    final asyncData = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل النشاط'),
      ),
      body: AsyncItemWidget<ActivityModel>(
        asyncData: asyncData,
        onRetry: () => ref.invalidate(provider),
        dataBuilder: (data) {
          return ActivityDetailsView(activity: data!);
        },
      ),
    );
  }
}
```

Customize loading, error, empty, and refresh UI:

```dart
AsyncItemWidget<ActivityModel>(
  asyncData: asyncData,
  onRetry: () => ref.invalidate(provider),
  loadingWidgetBuilder: () => const ActivityDetailsSkeleton(),
  emptyWidgetBuilder: (context) => const EmptyActivityView(),
  errorWidgetBuilder: (error) {
    return RetryErrorView(
      message: error,
      onRetry: () => ref.invalidate(provider),
    );
  },
  refreshingBuilder: (context, child) {
    return Stack(
      children: [
        child,
        const Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: LinearProgressIndicator(),
        ),
      ],
    );
  },
  dataBuilder: (data) => ActivityDetailsView(activity: data!),
);
```

Tips:

- Use `AsyncItemWidget` when the default loading/error/empty behavior fits.
- Use `refreshingBuilder` when `innerloading` should display a non-blocking indicator.
- Keep `dataBuilder` focused on rendering the model, not fetching it.

Warnings:

- `dataBuilder` receives `T?` because `ItemStateModel<T>` can be empty. Handle null or use `AsyncItemWidget` empty behavior.
- Do not call `ref.invalidate` unconditionally during build.
- Do not show snackbars directly inside `dataBuilder`.

## AsyncWidget For Custom Layouts

Use `AsyncWidget<T>` when `AsyncItemWidget` or `AsyncListWidget` does not match the layout.

```dart
class ActivitiesTab extends ConsumerWidget {
  const ActivitiesTab({
    super.key,
    required this.selectedType,
  });

  final ActivityType selectedType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = listActivitiesProvider(selectedType);
    final asyncData = ref.watch(provider);

    return AsyncWidget<PaginatedDataModel<ActivityModel>?>(
      asyncData: asyncData,
      loadingBuilder: () {
        return const ActivitiesGridSkeleton();
      },
      errorBuilder: (error) {
        return RetryErrorView(
          message: error,
          onRetry: () => ref.invalidate(provider),
        );
      },
      refreshingBuilder: (context, child) {
        return Stack(
          children: [
            child,
            const Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(),
            ),
          ],
        );
      },
      dataBuilder: (data) {
        final items = data?.data ?? const <ActivityModel>[];
        if (items.isEmpty) {
          return const EmptyActivityView();
        }

        return ActivitiesGrid(
          items: items,
          onRefresh: () {
            return ref.read(provider.notifier).refresh();
          },
        );
      },
    );
  }
}
```

Tips:

- Use `AsyncWidget` for screens with tabs, slivers, grids, custom refresh controls, or complex layout composition.
- The `refreshingBuilder` receives the already-built data child. Wrap it without changing its layout.

Warnings:

- Do not assume `data` is non-null when the state type is nullable.
- Do not rebuild provider family arguments from unstable objects.

## AsyncListWidget

Use `AsyncListWidget<T>` for a simple list plus optional pagination widget.

```dart
AsyncListWidget<ActivityModel>(
  asyncData: asyncData,
  onRetry: () => ref.invalidate(provider),
  onPageChanged: (page) {
    ref.read(provider.notifier).getActivities(page: page);
  },
  dataBuilder: (items) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return ActivityTile(activity: items[index]);
      },
    );
  },
);
```

Without pagination:

```dart
AsyncListWidget<ActivityModel>(
  asyncData: asyncData,
  onRetry: () => ref.invalidate(provider),
  onPageChanged: null,
  emptyWidgetBuilder: (context) => const EmptyActivityView(),
  dataBuilder: (items) => ActivitiesGrid(items: items),
);
```

Tips:

- Pass `onPageChanged` only when the endpoint is page-based and UI should show page buttons.
- Use custom `AsyncWidget` for infinite scrolling or slivers.

Warnings:

- `AsyncListWidget` wraps the data and pagination in a `Column`. Avoid placing it directly inside an unconstrained scrollable unless the child layout handles constraints.
- For infinite scrolling, do not use `PaginationWidget`; use provider methods like `onLoadingMore`.

## Pull To Refresh

Combine Flutter `RefreshIndicator` with `innerloading`.

```dart
RefreshIndicator(
  onRefresh: () {
    return ref.read(provider.notifier).refresh();
  },
  child: AsyncWidget<PaginatedDataModel<ActivityModel>?>(
    asyncData: asyncData,
    loadingBuilder: () => const ActivitiesGridSkeleton(),
    errorBuilder: (error) {
      return RetryErrorView(
        message: error,
        onRetry: () => ref.invalidate(provider),
      );
    },
    refreshingBuilder: (context, child) {
      return child;
    },
    dataBuilder: (data) {
      return ListView.builder(
        itemCount: data?.data.length ?? 0,
        itemBuilder: (context, index) {
          return ActivityTile(activity: data!.data[index]);
        },
      );
    },
  ),
);
```

## PaginationWidget

Use `PaginationWidget` when rendering page buttons from `PaginationModel`.

```dart
PaginationWidget(
  pagination: asyncData.dataModel!.pagination,
  onChangePage: (page) {
    ref.read(provider.notifier).getActivities(page: page);
  },
);
```

The widget uses `PaginationModel.window`, so page-window logic stays out of the UI.

Tips:

- Keep `PaginationModel` from the repository response.
- Let provider load the requested page.
- Let `PaginationWidget` only render available pages and gaps.

Warnings:

- Do not mutate `PaginationModel` in the widget.
- Do not store current page in the widget if the provider already owns it.

## Documentation Links

- Flutter widgets: https://docs.flutter.dev/ui/widgets
- Flutter layout constraints: https://docs.flutter.dev/ui/layout/constraints
- Flutter `RefreshIndicator`: https://api.flutter.dev/flutter/material/RefreshIndicator-class.html
- Riverpod consumers: https://riverpod.dev/docs/concepts2/consumers
- Flutter performance best practices: https://docs.flutter.dev/perf/best-practices
