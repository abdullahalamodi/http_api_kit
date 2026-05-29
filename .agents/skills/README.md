# http_api_kit Agent Skills

These skills document how to use `http_api_kit` in app repositories, Riverpod providers, widgets, action flows, and model mapping.

## Skills

- `http-api-kit-repositories`: use for repository methods that call `HttpApi` and return typed models.
- `http-api-kit-riverpod-providers`: use for `StateNotifierProvider` patterns with `ItemStateModel` and `ListStateModel`.
- `http-api-kit-async-widgets`: use for `AsyncWidget`, `AsyncItemWidget`, `AsyncListWidget`, and `PaginationWidget` UI composition.
- `http-api-kit-actions`: use for command/action flows, `ActionState`, `ActionStateModel`, and `ref.listen` side effects.
- `http-api-kit-model-mapping`: use for safe response map conversion, nested objects, list parsing, filters, and pagination mapping.

## Default Guidance

Prefer the package barrel in app code:

```dart
import 'package:http_api_kit/http_api_kit.dart';
```

Keep responsibilities separated:

- Repositories call HTTP APIs and map backend data to typed models.
- Providers own async flow, loading flags, error messages, and pagination decisions.
- Widgets render state and emit user callbacks.
- Action providers emit one-off command results; views listen and perform side effects.
