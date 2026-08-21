# http_api_kit Model Mapping And Pagination

Use this skill when converting backend response maps into app models, lists, pagination objects, `PaginatedDataModel<T>`, and `PaginatedStateModel<T>`.

## Goal

Mapping should be predictable, typed, and isolated at the repository boundary. Views and providers receive clean Dart models — never raw JSON or dynamic maps.

## Naming Convention

| Model kind | Example | Pattern |
|---|---|---|
| Domain entity | `UserModel`, `OrderModel` | `PascalCase` + `Model` suffix |
| Body / DTO | `CreateUserBody`, `LoginBody` | `Verb + Noun` + `Body` suffix |
| Response wrapper | `StandardResponseModel` | Package-owned; not app-defined |
| Paginated wrapper | `PaginatedDataModel<T>` | Package-owned; not app-defined |

Keep model factory methods consistent: always `fromMap(Map<String, dynamic>)`.

## Single Model Mapping

Always copy `response.data` before parsing:

```dart
dataMapper: (response) {
  final data = Map<String, dynamic>.from(response.data);
  return UserModel.fromMap(data);
}
```

Why:

- `response.data` is `dynamic`. `Map<String, dynamic>.from` gives model factories a predictable shape and fails early if the backend returns an unexpected type.

Avoid:

```dart
dataMapper: (response) => UserModel.fromMap(response.data);
```

## Nested Model Mapping

Copy each nested map before parsing or mutation.

```dart
dataMapper: (response) {
  final root = Map<String, dynamic>.from(response.data);
  final order = Map<String, dynamic>.from(root['order']);

  final customer = order['customer'];
  if (customer != null) {
    order['customer'] = CustomerModel.fromMap(
      Map<String, dynamic>.from(customer),
    );
  }

  final items = (order['line_items'] as List).map(
    (item) => LineItemModel.fromMap(
      Map<String, dynamic>.from(item),
    ),
  ).toList();
  order['line_items'] = items;

  return OrderModel.fromMap(order);
}
```

Clean code tips:

- Name local maps after their domain meaning: `order`, `customer`, `pagination`.
- Convert lists and maps at the boundary, not after passing them around.
- Keep backend normalization (type discriminators, key renaming) inside the mapper.

Warnings:

- Do not mutate a map returned by the HTTP client without copying it first (`Map<String, dynamic>.from`).
- Do not spread nullable maps without a null check.
- Do not call model factories with `dynamic` — cast to `Map<String, dynamic>` first.

## Backend Normalization

When the backend sends a type discriminator separately, normalize before constructing the model.

```dart
dataMapper: (response) {
  final data = Map<String, dynamic>.from(response.data);
  final item = Map<String, dynamic>.from(data['item']);

  final kind = item['kind'] as String;
  final type = kind == 'premium' ? ItemType.premium : ItemType.standard;

  final details = Map<String, dynamic>.from(item['details']);
  details['type'] = type.name;

  item['details'] = ItemModel.fromMapWithType(details, type);

  return OrderItemModel.fromMap(item);
}
```

Why:

- Domain models should not know every inconsistent backend shape.
- Normalization keeps view and provider code clean.

## List Mapping

```dart
List<UserModel> _mapUsers(dynamic value) {
  return List<UserModel>.from(
    (value as List).map(
      (item) => UserModel.fromMap(
        Map<String, dynamic>.from(item),
      ),
    ),
  );
}
```

Usage inside a repository:

```dart
dataMapper: (response) {
  final data = Map<String, dynamic>.from(response.data);
  return _mapUsers(data['users']);
}
```

Warnings:

- Avoid `List<T>.from(response.data.map(...))` if `response.data` is `dynamic` and not first cast as a list.
- Always copy each list element with `Map<String, dynamic>.from(item)`.

## PaginatedDataModel Mapping

Use this reusable pattern for any paginated endpoint:

```dart
PaginatedDataModel<T> _mapPaginated<T>({
  required dynamic responseData,
  required String itemsKey,
  required T Function(Map<String, dynamic>) fromMap,
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

  return PaginatedDataModel<T>(
    data: items,
    pagination: pagination,
  );
}
```

Example:

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

## PaginationModel

`PaginationModel` represents server pagination metadata:

```dart
final pagination = PaginationModel.fromJson(
  Map<String, dynamic>.from(data['pagination']),
);
```

For UI page buttons, use `PaginationModel.window`:

```dart
final window = pagination.window;

for (final page in window.pages) {
  // render page button or ellipsis
}
```

Compute `noMore` in the provider:

```dart
bool get noMore {
  final pagination = state.dataModel?.pagination;
  return pagination == null ||
      pagination.totalPages == 0 ||
      pagination.currentPage == pagination.totalPages;
}
```

Clean code tips:

- Keep `PaginationModel` parsing in the repository.
- Keep pagination loading decisions in the provider.
- Keep pagination rendering in the widget.
- Use `PaginationModel` read-only — do not mutate it.

Warnings:

- Do not duplicate page-window logic in multiple widgets. `PaginationModel.window` already handles ellipsis gaps.
- Do not treat `totalPages == 0` and `currentPage == totalPages` as identical unless the product behavior intentionally matches.
- Do not append new page data when filters changed. Reset the list.

## PaginatedStateModel

`PaginatedStateModel<T>` is the provider-side state model for paginated data. It extends `BaseStateModel<PaginatedDataModel<T>?>` and provides:

| Method | Purpose |
|---|---|
| `withLoading()` | First load |
| `withInnerLoading()` | Refresh in place |
| `withData(data)` | Replace data |
| `appendData(newData)` | Append next page (auto-detects page 1) |
| `withError(message, data:?)` | Error with optional fallback data |

```dart
// Provider
state = state.withData(data);

// Append for infinite scroll
state = state.appendData(nextData);

// Error while keeping existing data
state = state.withError(message, data: state.dataModel);
```

## Filter Parameters

Build filter parameters in repository methods:

```dart
parameters: {
  'limit': filters.limit,
  'page': filters.page,
  'filter[status]': filters.status,
  ...filters.customFilters,
},
```

Clean code tips:

- Keep `FilterModel` immutable. Use `copyWith(page: page)` for pagination.
- Use backend key constants for repeated filter names.

Warnings:

- Do not let widgets build raw API filter keys.
- Do not mutate `filters.customFilters` before spreading it.

## Null Safety Guidelines

Prefer explicit checks:

```dart
final customer = order['customer'];
if (customer != null) {
  order['customer'] = CustomerModel.fromMap(
    Map<String, dynamic>.from(customer),
  );
}
```

Avoid:

```dart
order['customer'] = CustomerModel.fromMap(order['customer']!);
```

Always copy before parsing, never assert with `!` on backend data that could be absent.

## Documentation Links

- Dart null safety: https://dart.dev/null-safety
- Dart generics: https://dart.dev/language/generics
- Dart maps: https://api.dart.dev/dart-core/Map-class.html
- Dart lists: https://api.dart.dev/dart-core/List-class.html
