# http_api_kit Action Flows

Use this skill when implementing user-triggered commands such as confirm, cancel, login, signup, delete, download, scan, or sync actions with `ActionState`, `ActionStateModel`, and Riverpod listeners.

## Goal

Action providers should represent one-off commands. Views should listen to action state and perform side effects such as snackbars, dialogs, navigation, and route pops.

Preferred new API:

```dart
ActionState<T, A extends Object>
```

Compatibility API:

```dart
ActionStateModel<T>
```

Prefer the new generic `ActionState<T, A>` for new code because the app owns the action enum.

## Define App-Owned Action Enum

```dart
enum ActivityAction {
  confirmAttendance,
  cancelAttendance,
  downloadTicket,
  syncReservations,
}
```

Why:

- Generic packages should not define app-specific actions.
- The app action enum documents the feature's commands.
- Listeners can branch safely by action type.

## New ActionState Provider

```dart
typedef _ActionState = ActionState<void, ActivityAction>;

final activityActionsProvider = StateNotifierProvider.autoDispose<
    ActivityActionsProvider, _ActionState>(
  (ref) {
    return ActivityActionsProvider(ref);
  },
);

class ActivityActionsProvider extends StateNotifier<_ActionState> {
  ActivityActionsProvider(this._ref) : super(const ActionState.init());

  final Ref _ref;

  void _updateLoading(bool value) {
    _ref.read(loadingProvider.notifier).state = value;
  }

  Future<void> confirm({
    required String type,
    required List<String> numbers,
  }) async {
    const action = ActivityAction.confirmAttendance;

    _updateLoading(true);

    try {
      await _ref.read(activitiesRepoProvider).confirmAttend(
            type: type,
            numbers: numbers,
          );

      state = const ActionState.success(action: action);
    } on HttpApiException catch (e) {
      state = ActionState.failure(e, action: action);
    } catch (e) {
      state = ActionState.failure(
        UnknownException(e.toString()),
        action: action,
      );
    } finally {
      _updateLoading(false);
    }
  }
}
```

Tips:

- Use `ActionState<void, A>` when the command only reports success or failure.
- Use `ActionState<T, A>` when the command returns data.
- Store the action in both success and failure so the listener can show action-specific messages.

Warnings:

- Do not use package-owned domain actions for new code.
- Do not navigate from the provider.
- Do not swallow non-`HttpApiException` errors silently.
- Do not leave global loading enabled if an exception occurs. Use `finally`.

## Action Returning Data

```dart
enum AuthAction {
  login,
  signup,
}

typedef _AuthActionState = ActionState<AuthModel, AuthAction>;

class AuthActionsProvider extends StateNotifier<_AuthActionState> {
  AuthActionsProvider(this._ref) : super(const ActionState.init());

  final Ref _ref;

  Future<void> login(LoginBody body) async {
    const action = AuthAction.login;

    try {
      final auth = await _ref.read(authRepoProvider).login(
            appType: AppType.user,
            body: body,
          );

      state = ActionState.success(
        data: auth,
        action: action,
      );
    } on HttpApiException catch (e) {
      state = ActionState.failure(e, action: action);
    }
  }
}
```

Listener:

```dart
void listenToAuthActions(WidgetRef ref, BuildContext context) {
  ref.listen(authActionsProvider, (previous, next) {
    next.when(
      init: () {},
      success: (auth, action) {
        if (action == AuthAction.login) {
          context.showSnackbarSuccess('تم تسجيل الدخول بنجاح');
          context.goNamed(AppRoutes.home);
        }
      },
      failure: (error, action) {
        context.showSnackbarError(error.message);
      },
    );
  });
}
```

## Compatibility With ActionStateModel

Existing code can stay on `ActionStateModel`:

```dart
final activityActionsProvider =
    StateNotifierProvider.autoDispose<
      ActivityActionsProvider,
      ActionStateModel<void>
    >(
  (ref) {
    return ActivityActionsProvider(ref);
  },
);

class ActivityActionsProvider extends StateNotifier<ActionStateModel<void>> {
  ActivityActionsProvider(this._ref) : super(const ActionStateModel.init());

  final Ref _ref;

  Future<void> confirm({
    required String type,
    required List<String> numbers,
  }) async {
    try {
      await _ref.read(activitiesRepoProvider).confirmAttend(
            type: type,
            numbers: numbers,
          );

      state = const ActionStateModel.success();
    } on HttpApiException catch (e) {
      state = ActionStateModel.exception(e);
    }
  }
}
```

Warning:

- `ActionStateModel` and `ActionType` are compatibility APIs. Prefer `ActionState<T, A>` for new code.

## Listen In Views

Call the listener from `build` in a `ConsumerWidget` or `ConsumerState`.

```dart
class ConfirmAttendancePage extends ConsumerWidget {
  const ConfirmAttendancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _listenToActionState(ref, context);

    return ConfirmAttendanceView(
      onConfirm: (numbers) {
        ref.read(activityActionsProvider.notifier).confirm(
              type: 'event',
              numbers: numbers,
            );
      },
    );
  }

  void _listenToActionState(WidgetRef ref, BuildContext context) {
    ref.listen(activityActionsProvider, (previous, next) {
      next.when(
        init: () {},
        success: (_, action) {
          if (action == ActivityAction.confirmAttendance) {
            context.showSnackbarSuccess('تم تأكيد الحضور بنجاح');
            Navigator.of(context).pop();
          }
        },
        failure: (error, action) {
          context.showSnackbarError(error.message);
        },
      );
    });
  }
}
```

Tips:

- Keep listeners close to the UI that owns the side effect.
- Compare `previous` and `next` if you need to prevent duplicate side effects.
- Use `action` to choose the correct success message.

Warnings:

- Do not use `ref.watch` for one-off side effects. Use `ref.listen`.
- Do not call `showSnackbar` after the widget is disposed. If using async callbacks directly in widgets, check `context.mounted`.
- Do not emit the exact same success state repeatedly if the listener depends on equality and may suppress duplicates.

## Multiple Actions In One Provider

```dart
class ActivityActionsProvider extends StateNotifier<_ActionState> {
  ActivityActionsProvider(this._ref) : super(const ActionState.init());

  final Ref _ref;

  Future<void> confirm({
    required String type,
    required List<String> numbers,
  }) {
    return _runVoidAction(
      action: ActivityAction.confirmAttendance,
      task: () {
        return _ref.read(activitiesRepoProvider).confirmAttend(
              type: type,
              numbers: numbers,
            );
      },
    );
  }

  Future<void> cancel(String reservationId) {
    return _runVoidAction(
      action: ActivityAction.cancelAttendance,
      task: () {
        return _ref
            .read(activitiesRepoProvider)
            .cancelReservation(reservationId);
      },
    );
  }

  Future<void> _runVoidAction({
    required ActivityAction action,
    required Future<void> Function() task,
  }) async {
    try {
      await task();
      state = ActionState.success(action: action);
    } on HttpApiException catch (e) {
      state = ActionState.failure(e, action: action);
    }
  }
}
```

## Documentation Links

- Riverpod `ref.listen`: https://riverpod.dev/docs/concepts2/refs
- Riverpod providers: https://riverpod.dev/docs/concepts2/providers
- Flutter navigation: https://docs.flutter.dev/ui/navigation
- Flutter snackbars: https://docs.flutter.dev/cookbook/design/snackbars
- Dart enums: https://dart.dev/language/enums
