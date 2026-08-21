# http_api_kit Async Widgets

Use this skill when building Flutter UI with `AsyncWidget`, `AsyncItemWidget`, `AsyncListWidget`, `AsyncPaginatedWidget`, `AsyncInfiniteScrollListWidget`, `PaginationWidget`, `ItemStateModel`, `PaginatedStateModel`, and `ListStateModel`.

## Goal

Widgets render state. They do not call repositories, parse JSON, or own pagination business rules. Loading, error, empty, and refresh states are handled declaratively through state models.

Preferred import:

```dart
import 'package:http_api_kit/http_api_kit.dart';
```

## AsyncItemWidget — Single Item

Use `AsyncItemWidget<T>` when the screen displays one optional item backed by `ItemStateModel<T>`.

```dart
class UserProfilePage extends ConsumerWidget {
  const UserProfilePage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = showUserProvider(userId);
    final asyncData = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: AsyncItemWidget<UserModel>(
        asyncData: asyncData,
        onRetry: () => ref.invalidate(provider),
        dataBuilder: (user) => UserProfileView(user: user!),
      ),
    );
  }
}
```

Customize loading, error, empty, and refresh UI:

```dart
AsyncItemWidget<UserModel>(
  asyncData: asyncData,
  onRetry: () => ref.invalidate(provider),
  loadingWidgetBuilder: () => const UserProfileSkeleton(),
  emptyWidgetBuilder: (context) => const EmptyUserView(),
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
  dataBuilder: (user) => UserProfileView(user: user!),
);
```

Clean code tips:

- Keep `dataBuilder` focused on rendering the model. Do not fetch data inside it.
- Use `refreshingBuilder` when `innerloading` should display a non-blocking indicator.
- `dataBuilder` receives `T?` — handle `null` with the built-in empty state or cast with `!` after verifying the model is always present.

Warnings:

- `AsyncItemWidget` shows the empty widget when `data` is `null`. If your model is always non-null in the data state, use `dataBuilder: (data) => View(data!)`.
- Do not call `ref.invalidate` unconditionally during `build`.
- Do not show snackbars or dialogs inside `dataBuilder`.

## AsyncWidget — Custom Layouts

Use `AsyncWidget<T>` when `AsyncItemWidget`, `AsyncListWidget`, or `AsyncPaginatedWidget` do not match the required layout. It accepts any `BaseStateModel<T>`.

```dart
class UserListTab extends ConsumerWidget {
  const UserListTab({super.key, required this.statusFilter});

  final String statusFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = listUsersProvider(statusFilter);
    final asyncData = ref.watch(provider);

    return AsyncWidget<PaginatedDataModel<UserModel>?>(
      asyncData: asyncData,
      loadingBuilder: () => const UserGridSkeleton(),
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
        final items = data?.data ?? const <UserModel>[];
        if (items.isEmpty) {
          return const EmptyUserListView();
        }
        return UserGridView(
          items: items,
          onRefresh: () => ref.read(provider.notifier).refresh(),
        );
      },
    );
  }
}
```

Clean code tips:

- Use `AsyncWidget` for screens with tabs, slivers, grids, custom refresh controls, or complex layout composition.
- The `refreshingBuilder` receives the already-built data child. Wrap it without changing its layout.

Warnings:

- Do not assume `data` is non-null when the state type is nullable.
- Do not rebuild provider family arguments from unstable objects (e.g. inline maps or lists).

## AsyncListWidget — Simple List

Use `AsyncListWidget<T>` for a flat list backed by `BaseStateModel<List<T>?>`.

```dart
AsyncListWidget<UserModel>(
  asyncData: asyncData,
  onRetry: () => ref.invalidate(provider),
  dataBuilder: (users) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return UserTile(user: users[index]);
      },
    );
  },
);
```

Custom empty state:

```dart
AsyncListWidget<UserModel>(
  asyncData: asyncData,
  onRetry: () => ref.invalidate(provider),
  emptyWidgetBuilder: (context) => const EmptyUserListView(),
  dataBuilder: (users) => UserListView(users: users),
);
```

Clean code tips:

- `AsyncListWidget` only handles loading/error/empty/data states without pagination.
- For paginated lists, use `AsyncPaginatedWidget` instead.
- For infinite scroll, use `AsyncInfiniteScrollListWidget`.

Warnings:

- `AsyncListWidget` wraps data in a simple widget. Do not place it directly inside an unconstrained scrollable unless the child layout handles constraints.

## AsyncPaginatedWidget — Paginated List

Use `AsyncPaginatedWidget<T>` when the provider returns `PaginatedDataModel<T>` and the UI should show page buttons (via `PaginationWidget`).

```dart
AsyncPaginatedWidget<UserModel>(
  asyncData: asyncData,
  onRetry: () => ref.invalidate(provider),
  onPageChanged: (page) {
    ref.read(provider.notifier).fetch(page: page);
  },
  dataBuilder: (users) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) => UserTile(user: users[index]),
    );
  },
);
```

Customize loading, error, empty, and refresh:

```dart
AsyncPaginatedWidget<UserModel>(
  asyncData: asyncData,
  onRetry: () => ref.invalidate(provider),
  onPageChanged: (page) {
    ref.read(provider.notifier).fetch(page: page);
  },
  loadingWidgetBuilder: () => const UserListSkeleton(),
  emptyWidgetBuilder: (context) => const EmptyUserListView(),
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
  dataBuilder: (users) => UserListView(users: users),
);
```

Clean code tips:

- `AsyncPaginatedWidget` renders `PaginationWidget` below the data. The widget uses `PaginationModel.window` so page-window logic stays out of the UI.
- Pass `onPageChanged` only when the endpoint is page-based.
- The `dataBuilder` receives `List<T>` (not `PaginatedDataModel<T>`) — pagination is handled separately.

Warnings:

- Do not mutate `PaginationModel` in the widget.
- Do not store the current page in the widget if the provider already owns it.

## AsyncInfiniteScrollListWidget — Infinite Scroll

Use `AsyncInfiniteScrollListWidget<T>` when the provider returns `PaginatedDataModel<T>` and the UI should load more items as the user scrolls.

```dart
AsyncInfiniteScrollListWidget<UserModel>(
  asyncData: asyncData,
  itemBuilder: (user) => UserTile(user: user),
  onLoadMore: (nextPage) {
    ref.read(provider.notifier).loadMore();
  },
  onRetry: () => ref.invalidate(provider),
);
```

Customize states:

```dart
AsyncInfiniteScrollListWidget<UserModel>(
  asyncData: asyncData,
  itemBuilder: (user) => UserTile(user: user),
  onLoadMore: (nextPage) {
    ref.read(provider.notifier).loadMore();
  },
  onRetry: () => ref.invalidate(provider),
  hasMore: (pagination) => pagination.nextPage != null,
  loadMoreThreshold: 200,
  emptyWidgetBuilder: (context) => const EmptyUserListView(),
  loadingWidgetBuilder: () => const UserListSkeleton(),
  errorWidgetBuilder: (error) {
    return RetryErrorView(
      message: error,
      onRetry: () => ref.invalidate(provider),
    );
  },
  loadingMoreWidgetBuilder: () => const Padding(
    padding: EdgeInsets.all(16),
    child: Center(child: CircularProgressIndicator()),
  ),
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
);
```

Clean code tips:

- Use `hasMore` to customize when the "load more" trigger activates. Defaults to `pagination.nextPage != null`.
- Use `loadMoreThreshold` (default 200px) to control how early the next page is fetched.
- The widget handles the `ScrollController` internally. Do not attach your own.
- The provider should use `loadMore()` which calls `appendData` on `PaginatedStateModel`.

Warnings:

- Do not use `AsyncPaginatedWidget` for infinite scrolling. Use `AsyncInfiniteScrollListWidget` instead.
- Do not ignore the `innerloading` state — the widget skips duplicate `onLoadMore` calls while loading the next page.

## Pull To Refresh

Combine Flutter `RefreshIndicator` with `innerloading`:

```dart
RefreshIndicator(
  onRefresh: () => ref.read(provider.notifier).refresh(),
  child: AsyncWidget<PaginatedDataModel<UserModel>?>(
    asyncData: asyncData,
    loadingBuilder: () => const UserGridSkeleton(),
    errorBuilder: (error) {
      return RetryErrorView(
        message: error,
        onRetry: () => ref.invalidate(provider),
      );
    },
    refreshingBuilder: (context, child) => child, // innerloading handled by RefreshIndicator
    dataBuilder: (data) {
      return ListView.builder(
        itemCount: data?.data.length ?? 0,
        itemBuilder: (context, index) =>
            UserTile(user: data!.data[index]),
      );
    },
  ),
);
```

## PaginationWidget

Use `PaginationWidget` standalone when rendering page buttons manually:

```dart
PaginationWidget(
  pagination: pagination,
  onChangePage: (page) {
    ref.read(provider.notifier).fetch(page: page);
  },
);
```

The widget uses `PaginationModel.window` with ellipsis gaps for large page counts.

## Documentation Links

- Flutter widgets: https://docs.flutter.dev/ui/widgets
- Flutter layout constraints: https://docs.flutter.dev/ui/layout/constraints
- Flutter `RefreshIndicator`: https://api.flutter.dev/flutter/material/RefreshIndicator-class.html
- Riverpod consumers: https://riverpod.dev/docs/concepts/consumers
