# http_api_kit Repository Methods

Use this skill when writing repository functions that call `HttpApi` methods from `package:http_api_kit/http_api_kit.dart`. The repository layer wraps `HttpApiInterface<StandardResponseModel>` and returns typed domain models to providers and views.

## Goal

Repositories own HTTP calls, endpoint construction, and response mapping. They hide JSON parsing and backend shapes from the rest of the app. UI, providers, and widgets must not parse response maps directly.

Preferred shape:

```dart
class UserRepository {
  UserRepository(this._httpApi);

  final HttpApiInterface<StandardResponseModel> _httpApi;

  Future<UserModel> showUser(String id) {
    return _httpApi.getItem<UserModel>(
      endPoint: '/users/$id',
      dataMapper: (response) {
        return UserModel.fromMap(
          Map<String, dynamic>.from(response.data),
        );
      },
    );
  }
}
```

## Naming Convention

| Method | Repository method | Purpose |
|---|---|---|
| `getItem` | `show` + noun | Single resource lookup |
| `getList` | `list` + plural noun | Paginated collection |
| `post` | `add`, `create`, `login`, `register` | Create or command |
| `put` | `update`, `edit` | Full or partial update |
| `delete` | `delete`, `remove` | Remove resource |
| `multipart` | `upload` + noun | File upload |
| `getFile` | `download` + noun | File download |

Examples: `showUser`, `listUsers`, `addUser`, `updateUser`, `deleteUser`, `uploadAvatar`, `downloadReport`.

## Imports

Use the package barrel in app code:

```dart
import 'package:http_api_kit/http_api_kit.dart';
```

Do not import from `lib/src/` paths in application code.

## POST — Create / Command

Use `post<T>` for commands that send JSON and return a typed result.

```dart
Future<UserModel> addUser(CreateUserBody body) {
  return _httpApi.post<UserModel>(
    endPoint: '/users',
    body: body.toMap(),
    dataMapper: (response) {
      return UserModel.fromMap(
        Map<String, dynamic>.from(response.data),
      );
    },
  );
}
```

Use `requestHeaders` for per-call overrides:

```dart
Future<UserModel> login({
  required Map<String, dynamic> credentials,
  required String token,
}) {
  return _httpApi.post<UserModel>(
    endPoint: '/auth/login',
    requestHeaders: {
      'X-Device-Token': token,
    },
    body: credentials,
    dataMapper: (response) {
      return UserModel.fromMap(
        Map<String, dynamic>.from(response.data),
      );
    },
  );
}
```

Clean code tips:

- Return typed domain models, never `ResponseModelInterface`.
- Prefer DTO/body objects with `toMap()` over raw maps when the body has more than two fields.
- Keep endpoint strings in a dedicated `EndPoints` class, not inline in repositories.
- Copy `response.data` with `Map<String, dynamic>.from` before passing to model factories.

Warnings:

- Do not access `response.data` as `dynamic` in multiple places. Convert once at the mapper boundary.
- Do not catch `HttpApiException` in repositories. Let providers catch and translate to UI state.
- Do not trigger navigation, snackbars, or Riverpod state changes inside repository methods.

## GET Item — Single Resource

Use `getItem<T>` for one resource or a lookup result.

```dart
Future<UserModel> showUser(String id) {
  return _httpApi.getItem<UserModel>(
    endPoint: '/users/$id',
    dataMapper: (response) {
      return UserModel.fromMap(
        Map<String, dynamic>.from(response.data),
      );
    },
  );
}
```

With query parameters:

```dart
Future<UserModel> showUserByEmail(String email) {
  return _httpApi.getItem<UserModel>(
    endPoint: '/users/lookup',
    parameters: {'email': email},
    dataMapper: (response) {
      return UserModel.fromMap(
        Map<String, dynamic>.from(response.data),
      );
    },
  );
}
```

Clean code tips:

- Name parameters with meaningful local variables when building complex query strings.
- Keep parameter-key constants (`'email'`, `'status'`) in a single place, not scattered across methods.

Warnings:

- Do not use `!` assertion on `response.data` unless the API contract guarantees it.
- Handle absent backend keys before calling `fromMap`.

## GET List — Paginated Collection

Use `getList<T>` for paginated endpoints. The repository returns a `PaginatedDataModel<T>` so the provider knows about current page and total pages.

```dart
Future<PaginatedDataModel<UserModel>> listUsers({
  int page = 1,
  int limit = 10,
  String? statusFilter,
}) {
  return _httpApi.getList<PaginatedDataModel<UserModel>>(
    endPoint: '/users',
    parameters: {
      'page': page,
      'limit': limit,
      if (statusFilter != null) 'filter[status]': statusFilter,
    },
    dataMapper: (response) {
      final data = Map<String, dynamic>.from(response.data);
      final items = List<UserModel>.from(
        (data['users'] as List).map(
          (item) => UserModel.fromMap(
            Map<String, dynamic>.from(item),
          ),
        ),
      );
      final pagination = PaginationModel.fromJson(
        Map<String, dynamic>.from(data['pagination']),
      );
      return PaginatedDataModel(
        data: items,
        pagination: pagination,
      );
    },
  );
}
```

Extract a reusable pagination helper when multiple endpoints share the same shape:

```dart
PaginatedDataModel<T> _mapPaginated<T>({
  required dynamic responseData,
  required String itemsKey,
  required T Function(Map<String, dynamic> map) fromMap,
}) {
  final data = Map<String, dynamic>.from(responseData);
  final items = List<T>.from(
    (data[itemsKey] as List).map(
      (item) => fromMap(Map<String, dynamic>.from(item)),
    ),
  );
  final pagination = PaginationModel.fromJson(
    Map<String, dynamic>.from(data['pagination']),
  );
  return PaginatedDataModel(data: items, pagination: pagination);
}
```

Usage:

```dart
Future<PaginatedDataModel<UserModel>> listUsers({
  int page = 1,
  int limit = 10,
}) {
  return _httpApi.getList<PaginatedDataModel<UserModel>>(
    endPoint: '/users',
    parameters: {'page': page, 'limit': limit},
    dataMapper: (response) {
      return _mapPaginated<UserModel>(
        responseData: response.data,
        itemsKey: 'users',
        fromMap: UserModel.fromMap,
      );
    },
  );
}
```

Warnings:

- Do not return `List<T>` when the UI needs pagination metadata.
- Do not let providers parse `PaginationModel`. Keep response-shape knowledge in the repository.
- Be explicit about backend keys (`'users'`, `'pagination'`). Use constants when a key appears in multiple repositories.

## PUT — Update

Use `put<T>` for updates:

```dart
Future<UserModel> updateUser({
  required String id,
  required UpdateUserBody body,
}) {
  return _httpApi.put<UserModel>(
    endPoint: '/users/$id',
    body: body.toMap(),
    dataMapper: (response) {
      return UserModel.fromMap(
        Map<String, dynamic>.from(response.data),
      );
    },
  );
}
```

## DELETE — Remove Resource

Use `delete<T>` for delete commands:

```dart
Future<void> deleteUser(String id) {
  return _httpApi.delete<void>(
    endPoint: '/users/$id',
    body: const {},
    dataMapper: (_) {},
  );
}
```

If the backend returns the deleted object, map it:

```dart
Future<UserModel> deleteUser(String id) {
  return _httpApi.delete<UserModel>(
    endPoint: '/users/$id',
    body: const {},
    dataMapper: (response) {
      return UserModel.fromMap(
        Map<String, dynamic>.from(response.data),
      );
    },
  );
}
```

Warnings:

- Be explicit about the return type. Return `void` when the backend sends no meaningful data.

## Multipart — File Upload

Use `multipart<T>` for file uploads.

```dart
Future<UploadResultModel> uploadAvatar({
  required String userId,
  required MultipartFile file,
}) {
  return _httpApi.multipart<UploadResultModel>(
    endPoint: '/users/$userId/avatar',
    fields: {'source': 'mobile'},
    files: [file],
    dataMapper: (response) {
      return UploadResultModel.fromMap(
        Map<String, dynamic>.from(response.data),
      );
    },
  );
}
```

Clean code tips:

- Put scalar metadata in `fields`.
- Put query parameters in `parameters`.
- Pass all files through `files`.

## GET File — Download

Use `getFile<T>` for binary downloads.

```dart
Future<Uint8List> downloadReport(String reportId) {
  return _httpApi.getFile<Uint8List>(
    endPoint: '/reports/$reportId/download',
    dataMapper: (bytes) => bytes,
  );
}
```

## Error Handling Boundary

Repositories should not catch errors. Let the exception propagate to the provider:

```dart
// Repository — do not catch
Future<UserModel> showUser(String id) {
  return _httpApi.getItem<UserModel>(
    endPoint: '/users/$id',
    dataMapper: (response) {
      return UserModel.fromMap(
        Map<String, dynamic>.from(response.data),
      );
    },
  );
}
```

```dart
// Provider — catch and translate to UI state
try {
  final user = await ref.read(userRepoProvider).showUser(id);
  state = state.withData(user);
} catch (e, s) {
  logger.logException(e, s);
  final message = e is HttpApiException ? e.message : e.toString();
  state = state.withError(message);
}
```

## Documentation Links

- Dart generics: https://dart.dev/language/generics
- Dart null safety: https://dart.dev/null-safety
- `http` package: https://pub.dev/packages/http
