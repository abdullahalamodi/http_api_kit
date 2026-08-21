# http_api_kit Riverpod Providers

Use this skill when creating Riverpod providers that consume `http_api_kit` repositories and expose `ItemStateModel<T>`, `PaginatedStateModel<T>`, or `ActionState<T, A>` to Flutter views.

## Goal

Providers own async flow, loading flags, errors, pagination, refresh behavior, and repository interaction. Repositories return typed data. Widgets render state. Keep providers thin — move mapping and endpoint logic into repositories.

## Naming Convention

| Pattern | Provider name | State type |
|---|---|---|
| Single item | `showXProvider` | `ItemStateModel<X>` |
| Paginated list | `listXProvider` | `PaginatedStateModel<X>` |
| Command / action | `verbXProvider` | `ActionState<T, A>` |

Examples: `showUserProvider`, `listUsersProvider`, `addUserProvider`, `loginUserProvider`, `deleteUserProvider`.

## Imports

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_api_kit/http_api_kit.dart';
```

Do not import `flutter_riverpod/legacy.dart`. `StateNotifierProvider` is available from the main barrel in Riverpod 2.x.

## Item Provider — Single Resource

Use `ItemStateModel<T>` for one object or a lookup result.

```dart
typedef _UserState = ItemStateModel<UserModel>;

final showUserProvider = StateNotifierProvider.autoDispose
    .family<ShowUserProvider, _UserState, String>(
  (ref, userId) {
    return ShowUserProvider(ref, userId);
  },
);

class ShowUserProvider extends StateNotifier<_UserState> {
  ShowUserProvider(this._ref, this.userId) : super(ItemStateModel.init()) {
    fetch();
  }

  final Ref _ref;
  final String userId;

  Future<void> fetch() async {
    state = state.copyWith(
      loading: state.dataModel == null,
      innerloading: state.dataModel != null,
      error: null,
    );

    try {
      final data = await _ref.read(userRepoProvider).showUser(userId);

      state = state.copyWith(
        loading: false,
        innerloading: false,
        error: null,
        data: data,
      );
    } catch (e, s) {
      logger.logException(e, s);
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

Clean code tips:

- Use `loading` for the first blocking load.
- Use `innerloading` for refresh-in-place when existing data should stay visible.
- Keep the family argument (`String` in the example) immutable and comparable.
- Prefer `copyWith` over mutable assignment. Use `withLoading()`, `withData()`, `withError()` when no custom cross-field logic is needed.
- Name the state typedef `_XState` as a private alias so the public surface stays clean.
- Log `StackTrace` with the error — never ignore it.

Warnings:

- Do not set `loading: true` when refreshing existing data, or the widget will swap data for the loading UI.
- Do not call `ref.watch` inside provider methods. Use `ref.read` for one-shot repository calls.
- Do not trigger navigation or snackbars from data providers. Side effects belong in UI listeners.
- Do not catch errors to return default values. Let error state propagate to the widget layer.

For retry, invalidate the provider from the widget:

```dart
ref.invalidate(showUserProvider(userId));
```

## Paginated List Provider

Use `PaginatedStateModel<T>` when the repository returns `PaginatedDataModel<T>`.

```dart
typedef _ListState = PaginatedStateModel<UserModel>;

final listUsersProvider = StateNotifierProvider.autoDispose
    .family<ListUsersProvider, _ListState, String>(
  (ref, statusFilter) {
    return ListUsersProvider(ref, statusFilter);
  },
);

class ListUsersProvider extends StateNotifier<_ListState> {
  ListUsersProvider(this._ref, this.statusFilter)
      : super(PaginatedStateModel.init()) {
    fetch();
  }

  final Ref _ref;
  final String statusFilter;

  Future<void> fetch({int page = 1, bool skipLoading = false}) async {
    final hasData = state.dataModel != null;

    if (!skipLoading) {
      state = state.copyWith(
        loading: !hasData,
        innerloading: hasData,
        error: null,
      );
    }

    try {
      final data = await _ref.read(userRepoProvider).listUsers(
            page: page,
            statusFilter: statusFilter,
          );

      state = state.withData(data);
    } catch (e, s) {
      logger.logException(e, s);
      final message = e is HttpApiException ? e.message : e.toString();

      state = state.withError(
        message,
        data: hasData ? state.dataModel : null,
      );
    }
  }

  bool get noMore {
    final pagination = state.dataModel?.pagination;
    return pagination == null ||
        pagination.totalPages == 0 ||
        pagination.currentPage == pagination.totalPages;
  }

  Future<bool> loadMore() async {
    final current = state.dataModel;
    if (current == null || noMore) return false;

    try {
      final nextPage = current.pagination.currentPage + 1;
      final nextData = await _ref.read(userRepoProvider).listUsers(
            page: nextPage,
            statusFilter: statusFilter,
          );

      state = state.appendData(nextData);
      return true;
    } catch (e, s) {
      logger.logException(e, s);
      return false;
    }
  }
}
```

Clean code tips:

- Use `appendData` from `PaginatedStateModel` for infinite-scroll page appending; it handles page-1 replacement vs subsequent appending automatically.
- For filter changes, reset to page 1 by reloading the provider.
- For pull-to-refresh, keep existing data visible and set `innerloading: true`.
- Keep `noMore` derived from state instead of a separate mutable flag.

Warnings:

- Do not call `state.dataModel!` unless the method already verified it is non-null.
- Do not replace data with `null` on a refresh error unless the initial load failed.
- Do not mix pagination logic into widgets. The provider decides what page to load.

## Filter-Change Pattern

```dart
Future<void> applyStatusFilter(String status) {
  // Replace the entire list; reset to page 1
  _ref.invalidate(listUsersProvider(status));
}
```

Or when the provider is not family-based:

```dart
Future<void> applyStatusFilter(String status) async {
  await fetch(page: 1);
}
```

## Refresh-In-Place

```dart
Future<void> refresh() async {
  final current = state.dataModel;

  state = state.copyWith(
    loading: current == null,
    innerloading: current != null,
    error: null,
  );

  try {
    final data = await _ref.read(userRepoProvider).listUsers(page: 1);
    state = state.withData(data);
  } catch (e, s) {
    logger.logException(e, s);
    final message = e is HttpApiException ? e.message : e.toString();
    state = state.withError(
      message,
      data: current,
    );
  }
}
```

## Provider Invalidation And Retry

For family providers:

```dart
final provider = showUserProvider(userId);

AsyncItemWidget<UserModel>(
  asyncData: ref.watch(provider),
  onRetry: () => ref.invalidate(provider),
  dataBuilder: (user) => UserProfileView(user!),
);
```

For paginated list:

```dart
final provider = listUsersProvider('active');

AsyncPaginatedWidget<UserModel>(
  asyncData: ref.watch(provider),
  onRetry: () => ref.invalidate(provider),
  onPageChanged: (page) {
    ref.read(provider.notifier).fetch(page: page);
  },
  dataBuilder: (users) => UserListView(users),
);
```

## Documentation Links

- Riverpod providers: https://riverpod.dev/docs/concepts/providers
- Riverpod `autoDispose`: https://riverpod.dev/docs/concepts/auto_dispose
- Riverpod families: https://riverpod.dev/docs/concepts/families
- Riverpod `ref.listen`: https://riverpod.dev/docs/concepts/refs
