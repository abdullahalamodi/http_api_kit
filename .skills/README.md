# http_api_kit Agent Skills

These skills document how to use `http_api_kit` in app repositories, Riverpod providers, widgets, action flows, and model mapping.

## Skills

- `http-api-kit-repositories`: use for repository methods that call `HttpApiInterface` and return typed models. Covers `getItem`, `getList`, `post`, `put`, `delete`, `multipart`, and `getFile`.
- `http-api-kit-riverpod-providers`: use for `StateNotifierProvider` patterns with `ItemStateModel`, `PaginatedStateModel`, and `ActionState`.
- `http-api-kit-async-widgets`: use for `AsyncWidget`, `AsyncItemWidget`, `AsyncListWidget`, `AsyncPaginatedWidget`, `AsyncInfiniteScrollListWidget`, and `PaginationWidget` UI composition.
- `http-api-kit-actions`: use for command/action flows, `CommandState<T>` for simple flows, `ActionState<T, A>` with app-owned enums, and `ref.listen` side effects.
- `http-api-kit-model-mapping`: use for safe response map conversion, nested objects, list parsing, pagination mapping, and `PaginatedStateModel`.

## Default Guidance

Prefer the package barrel in app code:

```dart
import 'package:http_api_kit/http_api_kit.dart';
```

Keep responsibilities separated:

- **Repositories** call HTTP APIs and map backend data to typed models. Use naming: `showUser`, `listUsers`, `addUser`, `updateUser`, `deleteUser`, `uploadAvatar`.
- **Providers** own async flow, loading flags, error messages, pagination decisions, and action lifecycle. Use naming: `showUserProvider`, `listUsersProvider`, `loginUserProvider`.
- **Widgets** render state and emit user callbacks. Use naming: `UserProfilePage`, `UserListPage`, `LoginPage`.
- **Action providers** emit one-off command results; views listen via `ref.listen` and perform navigation or snackbar side effects.
