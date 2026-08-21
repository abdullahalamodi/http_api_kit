---
name: http-api-kit-riverpod-providers
description: Integrate http_api_kit state models with Riverpod in an app that already depends on flutter_riverpod.
---

# http_api_kit with Riverpod

Use this skill only when the consuming app has added `flutter_riverpod`. `http_api_kit` does not depend on or export Riverpod.

Import Riverpod from the app dependency and the package models from the public barrel:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_api_kit/http_api_kit.dart';
```

## Data providers

Keep repository calls and state transitions in the provider. Widgets read state and invoke methods or retry callbacks.

```dart
typedef _UserState = ItemStateModel<UserModel>;

final showUserProvider = StateNotifierProvider.autoDispose
    .family<ShowUserController, _UserState, String>(
  (ref, id) => ShowUserController(ref.read(userRepositoryProvider), id),
);

class ShowUserController extends StateNotifier<_UserState> {
  ShowUserController(this._repository, this._id) : super(ItemStateModel.init()) {
    fetch();
  }

  final UserRepository _repository;
  final String _id;

  Future<void> fetch() async {
    final hadData = state.dataModel != null;
    state = hadData ? state.withInnerLoading() : state.withLoading();
    try {
      state = state.withData(await _repository.showUser(_id));
    } on HttpApiException catch (error) {
      state = state.withError(error.message, data: state.dataModel);
    }
  }
}
```

Use `PaginatedStateModel<T>` for `PaginatedDataModel<T>`. Load page one with `withData`; call `appendData` for later pages. `appendData` replaces the list when the returned page is one and appends otherwise.

## UI integration

Pass the watched state to `AsyncItemWidget`, `AsyncListWidget`, `AsyncPaginatedWidget`, or `AsyncInfiniteScrollListWidget`. Invalidate or call a controller method from the retry callback.

Use `ref.listen` for one-off effects from `ActionState`; use `ref.watch` for rendering. Keep Riverpod imports and provider classes in the host app, never in this package.
