# http_api_kit Repository Methods

Use this skill when writing repository functions that call `HttpApi` methods from `package:http_api_kit/http_api_kit.dart`, especially `post`, `getItem`, `getList`, `put`, `delete`, `multipart`, and `getFile`.

## Goal

Repository methods should hide HTTP details from the app layer and return typed models. UI and providers should not parse response maps directly.

Preferred shape:

```dart
class AuthRepository {
  AuthRepository(this._httpApi);

  final HttpApiInterface<StandardResponseModel> _httpApi;

  Future<AuthModel> login({
    required AppType appType,
    required Map<String, dynamic> body,
  }) {
    return _httpApi.post<AuthModel>(
      endPoint: EndPoints.login(appType.endpointPrefix),
      body: body,
      dataMapper: (model) {
        return AuthModel.fromMap(
          Map<String, dynamic>.from(model.data),
        );
      },
    );
  }
}
```

## Imports

Use the package barrel in app code:

```dart
import 'package:http_api_kit/http_api_kit.dart';
```

Use focused imports only when the app intentionally wants a smaller public surface:

```dart
import 'package:http_api_kit/http_api.dart';
```

## POST Example

Use `post<T>` for commands that send JSON and return a typed result.

```dart
Future<AuthModel> login({
  required AppType appType,
  required LoginBody body,
}) async {
  final response = await _httpApi.post<AuthModel>(
    endPoint: EndPoints.login(appType.endpointPrefix),
    body: body.toMap(),
    dataMapper: (model) {
      final data = Map<String, dynamic>.from(model.data);
      return AuthModel.fromMap(data);
    },
  );

  return response;
}
```

Use `requestHeaders` for per-call overrides:

```dart
Future<AuthModel> loginAsGuest({
  required Map<String, dynamic> body,
}) {
  return _httpApi.post<AuthModel>(
    endPoint: EndPoints.guestLogin,
    requestHeaders: {
      'X-Guest-Flow': 'true',
    },
    body: body,
    dataMapper: (model) {
      return AuthModel.fromMap(
        Map<String, dynamic>.from(model.data),
      );
    },
  );
}
```

Tips:

- Always return typed domain models from repositories, not `ResponseModelInterface`.
- Prefer DTO/body objects with `toMap()` over inline body maps when the body has more than two fields.
- Use `Map<String, dynamic>.from(model.data)` before passing data into model factories.
- Keep endpoint construction in `EndPoints`, not inside provider or widget code.

Warnings:

- Do not access `model.data` as `dynamic` in multiple places. Convert once at the mapper boundary.
- Do not catch `HttpApiException` in repositories unless the repository can add useful domain context. Let providers catch and convert to UI state.
- Do not place UI messages, snackbars, navigation, or Riverpod state changes inside repository methods.

## GET Item Example

Use `getItem<T>` for a single resource or lookup result.

```dart
Future<AttendanceResultModel> scanReservation(
  ScanFamily scanFamily,
) async {
  final response = await _httpApi.getItem<AttendanceResultModel>(
    endPoint: EndPoints.lookupBarcode,
    parameters: {
      'number': scanFamily.number,
      'type': _scanTypeParam(scanFamily.type),
    },
    dataMapper: (model) {
      final data = Map<String, dynamic>.from(model.data);
      final reservation = Map<String, dynamic>.from(data['reservation']);

      final reservableType = reservation['reservable_type'] as String;
      final activityType = reservableType == 'Card'
          ? ActivityType.cards
          : ActivityType.events;

      final reservable = Map<String, dynamic>.from(
        reservation['reservable'],
      );
      reservable['type'] = activityType.name;

      reservation['reservable'] = ActivityModel.fromMapWithType(
        reservable,
        activityType,
      );

      final applicant = reservation['applicant'];
      if (applicant != null) {
        reservation['applicant'] = ApplicantModel.fromMap(
          Map<String, dynamic>.from(applicant),
        );
      }

      return AttendanceResultModel.fromMap(reservation);
    },
  );

  return response;
}
```

Tips:

- Use local variables with meaningful names for nested maps.
- Convert nested maps before mutating them.
- Normalize backend-specific fields inside the mapper, so the rest of the app receives clean models.

Warnings:

- Avoid mutating `model.data` directly. Copy into a new map first.
- Avoid null assertions on backend fields unless the API contract guarantees them.
- If a backend key can be absent, handle it before calling `fromMap`.

## GET List With Pagination Example

Use `getList<PaginatedDataModel<T>>` when the backend returns data plus pagination metadata.

```dart
Future<PaginatedDataModel<ActivityReservationModel>> getActivityReservations({
  required ReservationsFamily family,
  required FilterModel filters,
}) async {
  final response =
      await _httpApi.getList<PaginatedDataModel<ActivityReservationModel>>(
    endPoint: EndPoints.activityReservations,
    parameters: {
      'limit': filters.limit,
      'page': filters.page,
      'filters[reservable_id]': family.reservableId,
      'filters[reservable_type]': family.reservableType.reservationsType,
      ...filters.customFilters,
    },
    dataMapper: (model) {
      final data = Map<String, dynamic>.from(model.data);
      final items = List<ActivityReservationModel>.from(
        (data[ResponseKeys.reservations] as List).map(
          (item) {
            return ActivityReservationModel.fromMap(
              Map<String, dynamic>.from(item),
            );
          },
        ),
      );

      final pagination = PaginationModel.fromJson(
        Map<String, dynamic>.from(data[ResponseKeys.pagination]),
      );

      return PaginatedDataModel(
        data: items,
        pagination: pagination,
      );
    },
  );

  return response;
}
```

For reusable list parsing, extract helpers:

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

Usage:

```dart
Future<PaginatedDataModel<ActivityModel>> getActivities({
  required ActivityType type,
  required FilterModel filters,
}) {
  return _httpApi.getList<PaginatedDataModel<ActivityModel>>(
    endPoint: EndPoints.activities,
    parameters: {
      'type': type.name,
      'page': filters.page,
      'limit': filters.limit,
      ...filters.customFilters,
    },
    dataMapper: (model) {
      return mapPaginatedData<ActivityModel>(
        model: model,
        itemsKey: ResponseKeys.activities,
        fromMap: ActivityModel.fromMap,
      );
    },
  );
}
```

Warnings:

- Do not return `List<T>` from a paginated endpoint if the UI needs `PaginationModel`.
- Do not let providers parse `PaginationModel`. Keep response-shape knowledge in repositories.
- Be explicit about backend keys such as `ResponseKeys.reservations` and `ResponseKeys.pagination`.

## PUT And DELETE Examples

Use `put<T>` for updates:

```dart
Future<ActivityModel> updateActivity({
  required String id,
  required ActivityUpdateBody body,
}) {
  return _httpApi.put<ActivityModel>(
    endPoint: EndPoints.activity(id),
    body: body.toMap(),
    dataMapper: (model) {
      return ActivityModel.fromMap(
        Map<String, dynamic>.from(model.data),
      );
    },
  );
}
```

Use `delete<T>` for delete commands:

```dart
Future<void> deleteActivity(String id) {
  return _httpApi.delete<void>(
    endPoint: EndPoints.activity(id),
    body: const {},
    dataMapper: (_) {},
  );
}
```

Warning:

- Keep delete response mapping explicit. If the backend returns deleted data, map it. If not, return `void`.

## Multipart Example

Use `multipart<T>` for file uploads.

```dart
Future<UploadResultModel> uploadAttachment({
  required String reservationId,
  required MultipartFile file,
}) {
  return _httpApi.multipart<UploadResultModel>(
    endPoint: EndPoints.attachments,
    parameters: {
      'reservation_id': reservationId,
    },
    fields: {
      'source': 'mobile',
    },
    files: [file],
    dataMapper: (model) {
      return UploadResultModel.fromMap(
        Map<String, dynamic>.from(model.data),
      );
    },
  );
}
```

Tips:

- Put scalar upload fields in `fields`.
- Put query parameters in `parameters`.
- Pass all files through `files`.

## Error Handling Boundary

Recommended repository behavior:

```dart
Future<ActivityModel> getActivity(String id) {
  return _httpApi.getItem<ActivityModel>(
    endPoint: EndPoints.activity(id),
    dataMapper: (model) {
      return ActivityModel.fromMap(
        Map<String, dynamic>.from(model.data),
      );
    },
  );
}
```

Recommended provider behavior:

```dart
try {
  final data = await ref.read(activitiesRepoProvider).getActivity(id);
  state = state.copyWith(loading: false, error: null, data: data);
} catch (e, s) {
  CustomLogger.exceptionLogger(error: e, stackTrace: s);
  final message = e is HttpApiException ? e.message : e.toString();
  state = state.copyWith(loading: false, error: message, data: null);
}
```

## Documentation Links

- Flutter networking cookbook: https://docs.flutter.dev/cookbook/networking/fetch-data
- Dart null safety: https://dart.dev/null-safety
- Dart generics: https://dart.dev/language/generics
- `http` package: https://pub.dev/packages/http
- Riverpod providers: https://riverpod.dev/docs/concepts2/providers
