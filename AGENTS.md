# Repository Guidelines

## Project Structure & Module Organization

This is a Flutter package named `http_api_kit`. The public package export is `lib/http_api_kit.dart`. Implementation code lives under `lib/src/` and is split into two modules:

- `lib/src/http_api/`: HTTP client core, config models, response models, localized messages, examples, and custom exceptions.
- `lib/src/async_widgets_kit/`: async state models, reusable widgets, pagination UI, and examples.

There is no `test/` directory or asset bundle currently. Add tests under `test/` and any future package assets under a declared `flutter.assets` section in `pubspec.yaml`.

## Build, Test, and Development Commands

- `flutter pub get`: install package dependencies.
- `dart format lib test`: format Dart code; omit `test` if it does not exist yet.
- `flutter analyze`: run static analysis using `analysis_options.yaml`.
- `flutter test`: run the Flutter test suite once tests are added.
- `dart pub publish --dry-run`: validate package metadata before publishing.

Run format and analysis before submitting changes.

## Coding Style & Naming Conventions

Follow `package:flutter_lints/flutter.yaml` plus the local `implementation_imports` rule. Prefer public imports from `package:http_api_kit/http_api_kit.dart` outside `lib/src/`; internal `lib/src/**` files may use implementation imports.

Use standard Dart style: two-space indentation, trailing commas for multi-line widget constructors and model initializers, `PascalCase` for classes and widgets, `camelCase` for methods, fields, and variables, and `snake_case.dart` for file names. Keep module barrel files such as `core.dart`, `models.dart`, and `exceptions.dart` updated when adding public module members.

## Testing Guidelines

Use `flutter_test` for unit and widget tests. Mirror source paths where practical, for example `test/http_api/core/http_api_test.dart` or `test/async_widgets_kit/core/async_widget_test.dart`. Name files with the `_test.dart` suffix and group tests around observable behavior: response parsing, exception mapping, pagination state, and loading/error/empty widget states.

When adding HTTP tests, prefer mocked clients or fakes over real network calls.

## Commit & Pull Request Guidelines

Recent commits use short imperative summaries, sometimes with a scope prefix such as `update:` or `expose:`. Keep commits concise and action-oriented, for example `update: handle response success flag` or `expose custom headers`.

Pull requests should include a brief description, linked issue when applicable, behavior changes, and test or analysis results. Include screenshots only for visible widget changes. Note any breaking API changes clearly in the PR and update `README.md` or `CHANGELOG.md` when public behavior changes.
