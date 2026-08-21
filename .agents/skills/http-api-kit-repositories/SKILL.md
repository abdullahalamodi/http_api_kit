---
name: http-api-kit-repositories
description: Implement typed repositories with HttpApi or HttpApiInterface, including JSON, multipart, download, and response-wrapper mapping.
---

# http_api_kit repositories

Use this skill for app repository methods backed by `http_api_kit`.

Import the public barrel:

```dart
import 'package:http_api_kit/http_api_kit.dart';
```

## Contract

Repositories own endpoint selection, request data, response parsing, and mapping to app models. Return typed values; keep raw response shapes out of state-management and widget code.

`HttpApi<R>` requires an `R extends ResponseModelInterface`. Use:

- `HttpApi<StandardResponseModel>` for envelopes containing `status_code`, `success`, `message`, and `data`.
- `HttpApi<DirectResponseModel>` with `responseParser: DirectResponseModel.fromMap` when a successful JSON response is the payload itself.
- a custom `ResponseModelInterface` plus `responseParser` (or a per-request `customResponseParser`) for another envelope shape.

```dart
class UserRepository {
  UserRepository(this._api);

  final HttpApiInterface<StandardResponseModel> _api;

  Future<UserModel> showUser(String id) {
    return _api.getItem(
      endPoint: '/users/$id',
      dataMapper: (response) => UserModel.fromMap(
        Map<String, dynamic>.from(response.data),
      ),
    );
  }
}
```

## Request choice

- `getItem`: retrieve one value.
- `getList`: retrieve a collection; it defaults to `GET` and accepts `method` when the API requires another supported JSON method.
- `post`, `put`, `delete`: JSON requests. Their `body` is required, including for an empty delete body: `body: const {}`.
- `multipart`: form fields and `http.MultipartFile` uploads. Supply an explicit method only when it is not `POST`.
- `getFile`: download bytes; its mapper receives `Uint8List`, not a response wrapper.

Use `parameters` for query parameters and `requestHeaders` for per-call header overrides. Package-level locale parameters and configured headers are merged automatically.

## Mapping boundaries

Copy dynamic maps and lists at the repository boundary before passing them to model factories:

```dart
dataMapper: (response) {
  final payload = Map<String, dynamic>.from(response.data);
  return UserModel.fromMap(payload);
},
```

For a paginated response, build both package models in the repository:

```dart
dataMapper: (response) {
  final payload = Map<String, dynamic>.from(response.data);
  return PaginatedDataModel(
    data: (payload['users'] as List)
        .map((item) => UserModel.fromMap(Map<String, dynamic>.from(item)))
        .toList(),
    pagination: PaginationModel.fromJson(
      Map<String, dynamic>.from(payload['pagination']),
    ),
  );
},
```

Let `HttpApiException` propagate. The caller decides how an error becomes state or UI.
