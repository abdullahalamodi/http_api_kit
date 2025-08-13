# HTTP API Kit

A comprehensive Flutter package that combines HTTP API client functionality with async UI widgets for seamless state management, error handling, and pagination support.

## Features

### 🌐 HTTP API Client
- **Robust HTTP client** with interceptors and logging
- **Automatic error handling** with custom exceptions
- **Internationalization support** for error messages
- **Request/response logging** with Talker integration
- **Configurable base URLs and authentication**

### 🎨 Async UI Widgets
- **AsyncWidget** - Handle loading, error, and data states
- **AsyncListWidget** - Display paginated lists with async data
- **AsyncItemWidget** - Manage single item async operations
- **PaginationWidget** - Built-in pagination controls
- **Simple UI components** - Loading, error, and empty state widgets

### 📊 State Management
- **BaseStateModel** - Foundation for async state management
- **ListStateModel** - Specialized for list data with pagination
- **ItemStateModel** - For single item operations
- **ActionStateModel** - Handle user actions and responses

## Getting Started

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  http_api_kit:
    git:
      url: https://github.com/alamodi/http_api_kit.git
```

Then import the package:

```dart
import 'package:http_api_kit/http_api_kit.dart';
```

## Usage

### HTTP API Client Setup

```dart
// Configure the HTTP API client
final config = HttpApiConfig(
  baseUrl: 'https://api.example.com',
  apiAccessKey: 'your-api-key',
  token: 'user-auth-token',
  locale: 'en',
);

// Create HTTP client with interceptors
final httpClient = InterceptedClient.build(
  interceptors: [
    TalkerHttpApiLogger(),
  ],
);

// Initialize the API client
final api = HttpApi(
  httpClient: httpClient,
  config: config,
);
```

### Making API Calls

```dart
// GET request
final user = await api.getItem<User>(
  endPoint: '/users/123',
  dataMapper: (response) => User.fromJson(response.data),
);

// POST request
final newUser = await api.post<User>(
  endPoint: '/users',
  body: {'name': 'John Doe', 'email': 'john@example.com'},
  dataMapper: (response) => User.fromJson(response.data),
);
```

### Using Async Widgets

```dart
class UserProfile extends StatelessWidget {
  final ItemStateModel<User> userState;

  @override
  Widget build(BuildContext context) {
    return AsyncWidget<User>(
      asyncData: userState,
      dataBuilder: (user) => Column(
        children: [
          Text(user.name),
          Text(user.email),
        ],
      ),
      loadingBuilder: () => CircularProgressIndicator(),
      errorBuilder: (error) => Text('Error: $error'),
      emptyBuilder: () => Text('No user data'),
    );
  }
}
```

### Pagination Support

```dart
class UsersList extends StatelessWidget {
  final ListStateModel<User> usersState;

  @override
  Widget build(BuildContext context) {
    return AsyncListWidget<User>(
      asyncData: usersState,
      itemBuilder: (user) => ListTile(
        title: Text(user.name),
        subtitle: Text(user.email),
      ),
      loadingBuilder: () => CircularProgressIndicator(),
      errorBuilder: (error) => Text('Error: $error'),
      emptyBuilder: () => Text('No users found'),
    );
  }
}
```

## State Management Models

### ItemStateModel
```dart
final userState = ItemStateModel<User>(
  loading: false,
  error: null,
  dataModel: user,
  innerloading: false,
);
```

### ListStateModel
```dart
final usersState = ListStateModel<User>(
  loading: false,
  error: null,
  dataModel: PaginatedDataModel(
    data: users,
    pagination: PaginationModel(
      currentPage: 1,
      totalPages: 5,
      hasNextPage: true,
    ),
  ),
  innerloading: false,
);
```

## Error Handling

The package includes comprehensive error handling with custom exceptions:

- **ServerException** - Server-side errors (4xx, 5xx)
- **InternetException** - Network connectivity issues
- **DataFormatException** - JSON parsing errors
- **UnknownException** - Unexpected errors

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
