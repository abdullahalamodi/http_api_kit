# http_api_kit Model Mapping And Pagination

Use this skill when converting backend response maps into app models, lists, pagination objects, and `PaginatedDataModel<T>`.

## Goal

Mapping should be predictable, typed, and isolated at the repository boundary. The rest of the app should receive clean Dart models.

## Single Model Mapping

Preferred:

```dart
dataMapper: (model) {
  final data = Map<String, dynamic>.from(model.data);
  return ActivityModel.fromMap(data);
}
```

Avoid:

```dart
dataMapper: (model) => ActivityModel.fromMap(model.data);
```

Why:

- `model.data` is `dynamic`.
- `Map<String, dynamic>.from` gives model factories a predictable shape.
- It fails early if the backend returns an unexpected type.

## Nested Model Mapping

For nested backend objects, copy each nested map before parsing or mutation.

```dart
dataMapper: (model) {
  final root = Map<String, dynamic>.from(model.data);
  final reservation = Map<String, dynamic>.from(root['reservation']);

  final applicant = reservation['applicant'];
  if (applicant != null) {
    reservation['applicant'] = ApplicantModel.fromMap(
      Map<String, dynamic>.from(applicant),
    );
  }

  final reservable = Map<String, dynamic>.from(reservation['reservable']);
  reservation['reservable'] = ActivityModel.fromMap(reservable);

  return AttendanceResultModel.fromMap(reservation);
}
```

Tips:

- Name maps after their domain meaning: `reservation`, `applicant`, `pagination`.
- Convert lists and maps at the boundary.
- Keep backend normalization inside the mapper.

Warnings:

- Do not mutate a map returned by the HTTP client without copying it first.
- Do not spread nullable maps without checking them.
- Do not call model factories with `dynamic`.

## Backend Normalization

When the backend sends a type discriminator separately, normalize before constructing the model.

```dart
dataMapper: (model) {
  final data = Map<String, dynamic>.from(model.data);
  final reservation = Map<String, dynamic>.from(data['reservation']);

  final reservableType = reservation['reservable_type'] as String;
  final activityType = reservableType == 'Card'
      ? ActivityType.cards
      : ActivityType.events;

  final reservable = Map<String, dynamic>.from(reservation['reservable']);
  reservable['type'] = activityType.name;

  reservation['reservable'] = ActivityModel.fromMapWithType(
    reservable,
    activityType,
  );

  return AttendanceResultModel.fromMap(reservation);
}
```

Why:

- Domain models should not know every inconsistent backend shape.
- Normalization keeps view and provider code clean.

## List Mapping

Preferred:

```dart
List<ActivityModel> mapActivities(dynamic value) {
  return List<ActivityModel>.from(
    (value as List).map(
      (item) {
        return ActivityModel.fromMap(
          Map<String, dynamic>.from(item),
        );
      },
    ),
  );
}
```

Use it inside repositories:

```dart
dataMapper: (model) {
  final data = Map<String, dynamic>.from(model.data);
  return mapActivities(data[ResponseKeys.activities]);
}
```

Warning:

- Avoid `List<T>.from(model.data.map(...))` if `model.data` is dynamic and not first checked or cast as a list.

## PaginatedDataModel Mapping

Use this shape for any paginated endpoint:

```dart
PaginatedDataModel<T> mapPaginatedData<T>({
  required ResponseModelInterface model,
  required String itemsKey,
  required T Function(Map<String, dynamic> map) fromMap,
}) {
  final data = Map<String, dynamic>.from(model.data);

  final items = List<T>.from(
    (data[itemsKey] as List).map(
      (item) => fromMap(Map<String, dynamic>.from(item)),
    ),
  );

  final pagination = PaginationModel.fromJson(
    Map<String, dynamic>.from(data[ResponseKeys.pagination]),
  );

  return PaginatedDataModel<T>(
    data: items,
    pagination: pagination,
  );
}
```

Example:

```dart
Future<PaginatedDataModel<ActivityReservationModel>> getReservations({
  required ReservationsFamily family,
  required FilterModel filters,
}) {
  return _httpApi.getList<PaginatedDataModel<ActivityReservationModel>>(
    endPoint: EndPoints.activityReservations,
    parameters: {
      'limit': filters.limit,
      'page': filters.page,
      'filters[reservable_id]': family.reservableId,
      'filters[reservable_type]': family.reservableType.reservationsType,
      ...filters.customFilters,
    },
    dataMapper: (model) {
      return mapPaginatedData<ActivityReservationModel>(
        model: model,
        itemsKey: ResponseKeys.reservations,
        fromMap: ActivityReservationModel.fromMap,
      );
    },
  );
}
```

## PaginationModel

`PaginationModel` should represent server pagination metadata.

```dart
final pagination = PaginationModel.fromJson(
  Map<String, dynamic>.from(data[ResponseKeys.pagination]),
);
```

Use `PaginationModel.window` for UI page buttons:

```dart
final window = pagination.window;

for (final page in window.pages) {
  // render page button
}
```

Tips:

- Use `currentPage` and `totalPages` to compute `noMore`.
- Keep pagination parsing in the repository.
- Keep pagination loading decisions in the provider.
- Keep pagination rendering in the widget.

Warnings:

- Do not duplicate page-window logic in multiple widgets.
- Do not treat `totalPages == 0` and `currentPage == totalPages` the same unless the product behavior is intentional.
- Do not append new page data when filters changed. Reset the list.

## Filter Parameters

Build filter parameters in repository methods:

```dart
parameters: {
  'limit': filters.limit,
  'page': filters.page,
  'filters[reservable_id]': family.reservableId,
  'filters[reservable_type]': family.reservableType.reservationsType,
  ...filters.customFilters,
},
```

Tips:

- Keep `FilterModel` immutable.
- Use `copyWith(page: page)` for pagination.
- Use backend key constants for repeated filter names.

Warnings:

- Do not let widgets build raw API filter keys.
- Do not mutate `filters.customFilters` before spreading it.

## Null Safety Guidelines

Prefer explicit checks:

```dart
final applicant = reservation['applicant'];
if (applicant != null) {
  reservation['applicant'] = ApplicantModel.fromMap(
    Map<String, dynamic>.from(applicant),
  );
}
```

Avoid:

```dart
reservation['applicant'] = ApplicantModel.fromMap(
  reservation['applicant']!,
);
```

## Documentation Links

- Dart null safety: https://dart.dev/null-safety
- Dart generics: https://dart.dev/language/generics
- Dart maps: https://api.dart.dev/dart-core/Map-class.html
- Dart lists: https://api.dart.dev/dart-core/List-class.html
- Flutter networking cookbook: https://docs.flutter.dev/cookbook/networking/fetch-data
