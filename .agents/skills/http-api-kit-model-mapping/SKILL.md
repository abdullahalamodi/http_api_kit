---
name: http-api-kit-model-mapping
description: Map HttpApi response payloads into typed app models, lists, and the package pagination models.
---

# http_api_kit model mapping

Use this skill when translating `ResponseModelInterface.data` into app-owned models.

Keep mapping at the repository boundary. Model factories receive concrete `Map<String, dynamic>` values; state and UI receive typed models.

## Single and nested values

```dart
final payload = Map<String, dynamic>.from(response.data);
final user = UserModel.fromMap(payload);
```

For nested objects and lists, validate the expected shape before converting. Copy every map passed to a factory:

```dart
final payload = Map<String, dynamic>.from(response.data);
final orders = (payload['orders'] as List)
    .map((value) => OrderModel.fromMap(Map<String, dynamic>.from(value)))
    .toList();
```

Use the API's actual field names in one place, preferably constants when they recur. Do not let `dynamic` escape the mapper.

## Pagination

`PaginatedDataModel<T>` contains the rendered values and a `PaginationModel`. Construct it when the backend supplies both:

```dart
PaginatedDataModel<UserModel>(
  data: users,
  pagination: PaginationModel.fromJson(
    Map<String, dynamic>.from(payload['pagination']),
  ),
)
```

`PaginationModel.fromJson` expects these keys and types:

```text
current_page: int       total_pages: int       total_entries: int
next_page: int?         previous_page: int?    per_page: int?
```

Use `pagination.nextPage` to determine whether more pages exist. `pagination.window` is for `PaginationWidget`; callers should not reproduce its page-window calculation.

## Response envelopes

The default `StandardResponseModel` reads `status_code`, `success`, `message`, and `data`. When the server uses a different shape, provide a custom `ResponseModelInterface` parser to `HttpApi` or the individual request; then map the resulting `data` as above.
