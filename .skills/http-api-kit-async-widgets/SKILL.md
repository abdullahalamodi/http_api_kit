---
name: http-api-kit-async-widgets
description: Build Flutter loading, error, empty, refresh, paginated, and infinite-scroll UI with http_api_kit state models and widgets.
---

# http_api_kit async widgets

Use this skill to render the package state models. The caller owns fetching and retry behavior; these widgets only render the supplied state and invoke callbacks.

```dart
import 'package:http_api_kit/http_api_kit.dart';
```

## Pick the narrowest widget

| State | Widget | Data callback |
|---|---|---|
| `BaseStateModel<T>` | `AsyncWidget<T>` | `T` |
| `ItemStateModel<T>` | `AsyncItemWidget<T>` | `T?` |
| `ListStateModel<T>` or `BaseStateModel<List<T>?>` | `AsyncListWidget<T>` | `List<T>` |
| `PaginatedStateModel<T>` or `BaseStateModel<PaginatedDataModel<T>?>` | `AsyncPaginatedWidget<T>` | `List<T>` |
| paginated infinite scrolling | `AsyncInfiniteScrollListWidget<T>` | one `T` per item |

`AsyncWidget` requires explicit loading and error builders. The specialized widgets provide `SimpleLoadingWidget`, `SimpleErrorWidget`, `SimpleEmptyWidget`, and `SimpleRefreshWidget` defaults.

```dart
AsyncItemWidget<UserModel>(
  asyncData: userState,
  onRetry: retry,
  dataBuilder: (user) => UserView(user: user!),
)
```

## State behavior

- `loading` renders the loading builder.
- a non-null `error` renders the error builder.
- `innerloading`/`isRefreshing` preserves the data child and wraps it with `refreshingBuilder` (or the default refresh widget).
- `AsyncItemWidget` treats null data as empty; list and paginated widgets treat null or empty data as empty.

Use `withLoading()` for an initial blocking load, `withInnerLoading()` only when existing data should remain visible, `withData(...)` for success, and `withError(...)` for a visible error. The state models are immutable; assign the returned instance in the app's state-management layer.

## Pagination

`AsyncPaginatedWidget` renders the data callback followed by a `PaginationWidget`; pass `onPageChanged` to load that page. Its callback receives only the list, while the package retains pagination metadata.

```dart
AsyncPaginatedWidget<UserModel>(
  asyncData: usersState,
  onRetry: retry,
  onPageChanged: loadPage,
  dataBuilder: (users) => UserList(users: users),
)
```

`AsyncInfiniteScrollListWidget` owns its `ScrollController`. Its `onLoadMore` receives the next page, and it loads by default while `pagination.nextPage != null`. Use `hasMore` only for a different backend rule; ensure it agrees with a non-null page passed to `onLoadMore`.

Keep navigation, snackbars, and repository calls outside builders.
