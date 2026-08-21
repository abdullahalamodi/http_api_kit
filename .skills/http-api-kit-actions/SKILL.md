---
name: http-api-kit-actions
description: Represent one-off app commands with CommandState or ActionState and handle their typed success or failure outcomes.
---

# http_api_kit action flows

Use this skill for login, save, delete, upload, and similar one-off commands. `http_api_kit` supplies state values; the host application chooses its state-management library and UI listener mechanism.

## Choose an action state

- `CommandState<T>` is `ActionState<T, SimpleAction>` for a single command identity.
- `ActionState<T, A>` carries an optional app-owned action enum when one state holder exposes several commands.
- `ActionStateModel<T>` and `ActionType` are deprecated compatibility APIs. Use `ActionState` for new work.

```dart
enum AccountAction { login, register }

ActionState<void, AccountAction> state = const ActionState.init();

Future<void> login() async {
  const action = AccountAction.login;
  try {
    await repository.login();
    state = const ActionState.success(action: action);
  } on HttpApiException catch (error) {
    state = ActionState.failure(error, action: action);
  }
}
```

For errors outside the HTTP client, convert them to an `HttpApiException` before emitting a failure. `UnknownException` is available for that purpose.

## Consume the result

Use `when` when every case matters and `whenOrNull` for selective handling:

```dart
state.when(
  init: () {},
  success: (data, action) {
    if (action == AccountAction.login) {
      // Perform the UI success effect here.
    }
  },
  failure: (exception, action) {
    // Surface exception.message here.
  },
);
```

Emit state from the command layer. Perform navigation, dialogs, snackbars, and other UI side effects in the app layer that observes state. Use the integration's own listener API (for example, Riverpod's `ref.listen`) only when that integration is a dependency of the host app; it is not a dependency of this package.
