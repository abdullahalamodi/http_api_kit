# http_api_kit Action Flows

Use this skill when implementing user-triggered commands — login, register, delete, confirm, upload, download, scan, sync — using `ActionState<T, A>` (or `CommandState<T>` for simple flows) and Riverpod `ref.listen`.

## Goal

Action providers encapsulate one-off commands. Views listen to action state and perform side effects: snackbars, dialogs, navigation, and route pops.

## Naming Convention

| Pattern | Provider name | State type |
|---|---|---|
| Void command (simple) | `verbXProvider` | `CommandState<void>` |
| Command with result (simple) | `verbXProvider` | `CommandState<T>` |
| Void command (custom actions) | `verbXProvider` | `ActionState<void, XAction>` |
| Command with result (custom actions) | `verbXProvider` | `ActionState<T, XAction>` |

Examples: `loginUserProvider` with `CommandState<void>`, `deleteUserProvider` with `CommandState<void>`, `uploadAvatarProvider` with `CommandState<UploadResultModel>`.

## Quick Start — CommandState (No Custom Enum)

Use `CommandState<T>` (an alias for `ActionState<T, SimpleAction>`) when you do not need to distinguish between different action types. Best for single-command providers or when the listener does not branch on action identity.

```dart
typedef _State = CommandState<void>;

final loginUserProvider =
    StateNotifierProvider.autoDispose<LoginUserProvider, _State>(
  (ref) => LoginUserProvider(ref),
);

class LoginUserProvider extends StateNotifier<_State> {
  LoginUserProvider(this._ref) : super(const CommandState.init());

  final Ref _ref;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _ref.read(authRepoProvider).login(
            email: email,
            password: password,
          );

      state = const CommandState.success();
    } on HttpApiException catch (e) {
      state = CommandState.failure(e);
    } catch (e) {
      state = CommandState.failure(
        UnknownException(e.toString()),
      );
    }
  }
}
```

Listener:

```dart
ref.listen(loginUserProvider, (previous, next) {
  next.when(
    init: () {},
    success: (_) {
      context.showSnackbar('Login successful');
      context.goNamed(AppRoutes.home);
    },
    failure: (error, _) {
      context.showSnackbar(error.message);
    },
  );
});
```

Clean code tips:

- `CommandState<void>` for fire-and-forget commands that only report success/failure.
- `CommandState<T>` for commands that return data (e.g. `CommandState<AuthModel>`).
- No custom enum needed — `SimpleAction.action` is the single discriminant.
- The `_` in the listener callbacks signals that you intentionally ignore the action parameter.

Warnings:

- If the listener must branch on different action types (e.g. `login` vs `register` in the same provider), switch to the custom-enum pattern below.

## Custom Actions — App-Owned Action Enum

Use `ActionState<T, A>` with a custom enum when the provider handles multiple command types and the listener must branch by action.

```dart
enum UserAction {
  login,
  register,
  delete,
  uploadAvatar,
}
```

Why:

- The app enum documents every command the feature supports.
- Listeners branch safely by action type without string comparisons.

## Action Provider — Void Command

Use `ActionState<void, A>` when the command only reports success or failure.

```dart
typedef _ActionState = ActionState<void, UserAction>;

final loginUserProvider =
    StateNotifierProvider.autoDispose<LoginUserProvider, _ActionState>(
  (ref) => LoginUserProvider(ref),
);

class LoginUserProvider extends StateNotifier<_ActionState> {
  LoginUserProvider(this._ref) : super(const ActionState.init());

  final Ref _ref;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    const action = UserAction.login;

    try {
      await _ref.read(authRepoProvider).login(
            email: email,
            password: password,
          );

      state = ActionState.success(action: action);
    } on HttpApiException catch (e) {
      state = ActionState.failure(e, action: action);
    } catch (e) {
      state = ActionState.failure(
        UnknownException(e.toString()),
        action: action,
      );
    }
  }
}
```

Clean code tips:

- Use `ActionState<void, A>` when there is no return data.
- Use `ActionState.failure` — not the deprecated `exception` factory.
- Use a local `const action` at the top of each method for self-documentation.
- Catch non-`HttpApiException` errors and wrap them in `UnknownException`.
- Do not navigate or show snackbars from the provider.

Warnings:

- Do not swallow errors silently. Every path must produce a state.
- Do not leave a loading flag enabled if an exception occurs.
- Do not access `ref.read` for non-repository services inside action providers. Keep them focused on the action lifecycle.

## Action Provider — Command With Data

Use `ActionState<T, A>` when the command returns typed data.

```dart
typedef _LoginState = ActionState<AuthModel, UserAction>;

final loginUserProvider =
    StateNotifierProvider.autoDispose<LoginUserProvider, _LoginState>(
  (ref) => LoginUserProvider(ref),
);

class LoginUserProvider extends StateNotifier<_LoginState> {
  LoginUserProvider(this._ref) : super(const ActionState.init());

  final Ref _ref;

  Future<void> login(CredentialsBody body) async {
    const action = UserAction.login;

    try {
      final auth = await _ref.read(authRepoProvider).login(body);

      state = ActionState.success(data: auth, action: action);
    } on HttpApiException catch (e) {
      state = ActionState.failure(e, action: action);
    }
  }
}
```

## Listen In Widgets

Use `ref.listen` in a `ConsumerWidget` or `ConsumerState` to perform side effects.

```dart
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _listenToLoginAction(ref, context);

    return LoginForm(
      onLogin: (email, password) {
        ref.read(loginUserProvider.notifier).login(
              email: email,
              password: password,
            );
      },
    );
  }

  void _listenToLoginAction(WidgetRef ref, BuildContext context) {
    ref.listen(loginUserProvider, (previous, next) {
      next.when(
        init: () {},
        success: (auth, action) {
          if (action == UserAction.login) {
            context.showSnackbar('Login successful');
            context.goNamed(AppRoutes.home);
          }
        },
        failure: (error, action) {
          context.showSnackbar(error.message);
        },
      );
    });
  }
}
```

Clean code tips:

- Keep listeners close to the UI that owns the side effect.
- Use `action` to choose the correct success message or navigation target.
- Compare `previous` and `next` if duplicate side-effect suppression is needed.

Warnings:

- Use `ref.listen`, not `ref.watch`, for one-off side effects.
- Check `context.mounted` before calling `showSnackbar` or `Navigator.pop` in async callbacks.
- Do not emit the same success state repeatedly if the listener depends on equality and may suppress duplicates.

## Multiple Actions In One Provider

Group related commands in a single provider to avoid duplication.

```dart
class UserActionsProvider extends StateNotifier<_ActionState> {
  UserActionsProvider(this._ref) : super(const ActionState.init());

  final Ref _ref;

  Future<void> login(CredentialsBody body) {
    return _run(
      action: UserAction.login,
      task: () => _ref.read(authRepoProvider).login(body),
    );
  }

  Future<void> deleteUser(String id) {
    return _runVoid(
      action: UserAction.delete,
      task: () => _ref.read(userRepoProvider).deleteUser(id),
    );
  }

  Future<void> _run<T>({
    required UserAction action,
    required Future<T> Function() task,
  }) async {
    try {
      final data = await task();
      state = ActionState.success(data: data, action: action);
    } on HttpApiException catch (e) {
      state = ActionState.failure(e, action: action);
    }
  }

  Future<void> _runVoid({
    required UserAction action,
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

Clean code tips:

- Extract `_run` and `_runVoid` helpers to reduce method body noise.
- Name action enum values as verb + noun: `login`, `deleteUser`, `uploadAvatar`.

Warnings:

- Do not mix unrelated domains in a single action provider. Group by feature boundary.
- Do not call `state =` more than once per method.

## Documentation Links

- Riverpod `ref.listen`: https://riverpod.dev/docs/concepts/refs
- Riverpod providers: https://riverpod.dev/docs/concepts/providers
- Flutter navigation: https://docs.flutter.dev/ui/navigation
- Dart enums: https://dart.dev/language/enums
