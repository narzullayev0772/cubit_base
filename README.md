[![Pub](https://img.shields.io/pub/v/cubit_base.svg)](https://pub.dev/packages/cubit_base) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![GitHub stars](https://img.shields.io/github/stars/narzullayev0772/cubit_base.svg?style=social)](https://github.com/narzullayev0772/cubit_base)

# Cubit Base

`cubit_base` is a Flutter package that simplifies state management in applications using the Cubit architecture. It offers utilities for easy API data fetching and pagination with minimal boilerplate, helping you manage asynchronous operations and state updates more effectively in your Flutter apps.

## Features

- **Simplified API Fetching**: Easily fetch data from APIs with built-in state management for loading, success, and error states.
- **Powerful Pagination Support**: Handle paginated data fetching efficiently with automatic page tracking and state updates.
- **Type-Safe State Management**: Leverages generic types to seamlessly work with your custom data models (e.g., `UserModel`, `NotificationModel`).
- **Status Change Callbacks**: Provides optional callbacks to monitor state changes during data fetching or pagination processes.
- **Reusable and Extensible**: Designed for easy integration with Cubit and can be adapted to any use case or repository pattern.

## Installation

Add `cubit_base` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  cubit_base: ^[latest_version] # Replace with the latest version
```

Run the following command to install the package:

```bash
flutter pub get
```

Then, import the package in your Dart code:

```dart
import 'package:cubit_base/cubit_base.dart';
```

## Usage

The `cubit_base` package primarily utilizes the `Fetcher` class, which provides two main static methods:

1.  **`fetchWithBase`**: For fetching single data items or a list of items from an API.
2.  **`fetchWithPaginate`**: For fetching paginated lists of data with automatic page handling and state management.

### Key Components

-   **`BaseState<T>`**: A fundamental state class for managing operations on single data items or non-paginated lists. It includes statuses like `initial`, `loading`, `success`, and `error`.
-   **`BasePaginationState<T>`**: A specialized state class for managing paginated data. It extends `BaseState` functionalities with pagination-specific statuses (e.g., `paging`) and properties like `currentPage` and `reachedMax`.
-   **`DataState<T>`**: A sealed class representing the outcome of an API call, which can be either `DataSuccess<T>` holding the data or `DataFailed<T>` containing error details.
-   **`Fetcher`**: A utility class containing static methods (`fetchWithBase` and `fetchWithPaginate`) that orchestrate the data fetching logic, state updates, and status emissions.

## Example

Below is an example demonstrating how to use `cubit_base` for both single data fetching and paginated data fetching.

### 1. Define Your Data Model and Cubit

Let's assume we have a `User` model and a `UserCubit` that manages the state for user-related data.

**`User` Model (Example)**
```dart
// user_model.dart
class User {
  final int id;
  final String name;

  User({required this.id, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
    );
  }
}
```

**`UserState`**
```dart
// user_state.dart
import 'package:cubit_base/cubit_base.dart';
import 'user_model.dart'; // Assuming your User model is in user_model.dart

class UserState {
  final BaseState<User> userProfileState;
  final BaseState<List<User>> usersListState;
  final BasePaginationState<User> paginatedUsersState;

  UserState({
    required this.userProfileState,
    required this.usersListState,
    required this.paginatedUsersState,
  });

  factory UserState.initial() => UserState(
        userProfileState: BaseState<User>.initial(),
        usersListState: BaseState<List<User>>.initial(),
        paginatedUsersState: BasePaginationState<User>(
          query: BaseQuery(page: 1, size: 10), // Initial query for pagination
        ),
      );

  UserState copyWith({
    BaseState<User>? userProfileState,
    BaseState<List<User>>? usersListState,
    BasePaginationState<User>? paginatedUsersState,
  }) {
    return UserState(
      userProfileState: userProfileState ?? this.userProfileState,
      usersListState: usersListState ?? this.usersListState,
      paginatedUsersState: paginatedUsersState ?? this.paginatedUsersState,
    );
  }
}
```

**`UserCubit`**
```dart
// user_cubit.dart
import 'package:bloc/bloc.dart';
import 'package.cubit_base/cubit_base.dart';
import 'user_state.dart'; // Your UserState
import 'user_repository.dart'; // Your UserRepository

class UserCubit extends Cubit<UserState> {
  final UserRepository _repository; // Assume you have a UserRepository

  UserCubit(this._repository) : super(UserState.initial());

  // Example: Fetch a single user profile
  Future<void> fetchUserProfile(int userId) async {
    await Fetcher.fetchWithBase<User>(
      fetcher: () => _repository.getUserProfile(userId), // This should return Future<DataState<User?>>
      state: state.userProfileState,
      emitter: (newState) => emit(state.copyWith(userProfileState: newState)),
      onStatusChange: (status) => print('User profile fetch status: $status'),
    );
  }

  // Example: Fetch a list of users (not paginated)
  Future<void> fetchUsersList() async {
    await Fetcher.fetchWithBase<List<User>>(
      fetcher: () => _repository.getUsersList(), // This should return Future<DataState<List<User>?>>
      state: state.usersListState,
      emitter: (newState) => emit(state.copyWith(usersListState: newState)),
      onStatusChange: (status) => print('Users list fetch status: $status'),
    );
  }

  // Example: Fetch a list of users with pagination
  Future<void> fetchPaginatedUsers() async {
    await Fetcher.fetchWithPaginate<User>(
      fetcher: (query) => _repository.getPaginatedUsers(query), // This should return Future<DataState<List<User>?>>
      state: state.paginatedUsersState,
      emitter: (newState) => emit(state.copyWith(paginatedUsersState: newState)),
      onStatusChange: (status) => print('Paginated users fetch status: $status'),
    );
  }

  // Call this method to load the next page for paginated users
  void fetchNextPaginatedUsersPage() {
    // The fetchWithPaginate method automatically handles page increment.
    // You just need to call the same method again.
    // It will use the updated page number from state.paginatedUsersState.query.page
    if (!state.paginatedUsersState.reachedMax && state.paginatedUsersState.status != DataStatus.paging) {
      fetchPaginatedUsers();
    }
  }
}
```
**`UserRepository` (Conceptual Example)**
```dart
// user_repository.dart
import 'package:cubit_base/cubit_base.dart';
import 'user_model.dart'; // Your User model

// Abstract class for the repository
abstract class UserRepository {
  Future<DataState<User?>> getUserProfile(int userId);
  Future<DataState<List<User>?>> getUsersList();
  Future<DataState<List<User>?>> getPaginatedUsers(BaseQuery query);
}

// Concrete implementation of the repository
class UserRepositoryImpl implements UserRepository {
  // Replace with your actual API calling logic (e.g., using http or dio)
  Future<DataState<User?>> _mockApiCallForUser(int userId) async {
    await Future.delayed(const Duration(seconds: 1));
    if (userId == 1) {
      return DataSuccess(User(id: 1, name: 'John Doe'));
    } else {
      return DataFailed(message: 'User not found', statusCode: 404);
    }
  }

  Future<DataState<List<User>?>> _mockApiCallForUsersList() async {
    await Future.delayed(const Duration(seconds: 1));
    return DataSuccess([
      User(id: 1, name: 'Alice'),
      User(id: 2, name: 'Bob'),
      User(id: 3, name: 'Charlie'),
    ]);
  }

  Future<DataState<List<User>?>> _mockApiCallForPaginatedUsers(BaseQuery query) async {
    await Future.delayed(const Duration(seconds: 1));
    int page = query.page;
    int size = query.size;
    // Simulate API behavior
    if (page > 2) { // Assume only 2 pages of data
      return DataSuccess([]); // Empty list indicates reachedMax
    }
    List<User> users = List.generate(size, (index) {
      final id = (page - 1) * size + index + 1;
      return User(id: id, name: 'User $id');
    });
    return DataSuccess(users);
  }

  @override
  Future<DataState<User?>> getUserProfile(int userId) async {
    // In a real app, you would make an HTTP request here.
    // Example: return _apiClient.get('/users/$userId');
    return _mockApiCallForUser(userId);
  }

  @override
  Future<DataState<List<User>?>> getUsersList() async {
    // Example: return _apiClient.get('/users');
    return _mockApiCallForUsersList();
  }

  @override
  Future<DataState<List<User>?>> getPaginatedUsers(BaseQuery query) async {
    // Example: return _apiClient.get('/users_paginated', queryParameters: {'page': query.page, 'size': query.size});
    print('Fetching page: ${query.page}, size: ${query.size}');
    return _mockApiCallForPaginatedUsers(query);
  }
}
```

### 2. Using `fetchWithBase`

Use `fetchWithBase` to fetch a single item (like a user profile) or a complete list of items (not paginated).

**In your UI or another part of your application logic:**
```dart
// Assuming userCubit is an instance of UserCubit available in your widget/context

// Fetch a single user profile
context.read<UserCubit>().fetchUserProfile(1);

// Fetch a list of all users (not paginated)
context.read<UserCubit>().fetchUsersList();
```

**How it works:**
- Sets `state.userProfileState.status` (or `usersListState.status`) to `loading`.
- Calls the `fetcher` function (e.g., `_repository.getUserProfile(userId)`).
- If successful, updates `state.userProfileState` with the fetched data and sets status to `success`.
- If failed, updates `state.userProfileState` with an error message and sets status to `error`.
- Optionally triggers `onStatusChange` callbacks for each status change.

### 3. Using `fetchWithPaginate`

Use `fetchWithPaginate` to fetch data in chunks (pages), such as a long list of users.

**In your UI or another part of your application logic:**
```dart
// Assuming userCubit is an instance of UserCubit

// Fetch the first page of paginated users
context.read<UserCubit>().fetchPaginatedUsers();

// To fetch the next page (e.g., in response to scrolling down a list):
// context.read<UserCubit>().fetchNextPaginatedUsersPage();
// This can be called from a scroll listener in a ListView.
```

**How it works:**
- **First page (`state.paginatedUsersState.query.page == 1`):**
    - Sets `state.paginatedUsersState.status` to `loading`.
    - Fetches the first page of data.
    - Replaces any existing list data with the new data.
    - Updates status to `success` or `error`.
    - Sets `reachedMax` if the fetched list is smaller than the page size or empty.
    - Increments `query.page` in the state for the next call.
- **Subsequent pages:**
    - Ensures `!reachedMax` and status is not already `paging`.
    - Sets `state.paginatedUsersState.status` to `paging`.
    - Fetches the next page of data using the incremented `query.page`.
    - Appends the new data to the existing list.
    - Updates `reachedMax` and increments `query.page`.
- Optionally triggers `onStatusChange` callbacks.

### 4. UI Integration Example

Integrate with your Flutter UI using `BlocBuilder` to react to state changes from your `UserCubit`.

**Paginated List Example:**
```dart
// user_list_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_cubit.dart'; // Your UserCubit
import 'user_state.dart'; // Your UserState
import 'user_model.dart'; // Your User model
// import 'user_repository.dart'; // Import if providing repository here

class UserListView extends StatefulWidget {
  @override
  _UserListViewState createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Example: Provide UserRepositoryImpl here if not already provided higher up the widget tree
    // final userRepository = UserRepositoryImpl();
    // final userCubit = UserCubit(userRepository);

    // Fetch initial data
    // context.read<UserCubit>().fetchPaginatedUsers(); // If UserCubit is provided via BlocProvider above this widget

    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch initial data if UserCubit is available and not already loading/loaded
    final userCubit = context.read<UserCubit>();
    if (userCubit.state.paginatedUsersState.status == DataStatus.initial &&
        userCubit.state.paginatedUsersState.data.isEmpty) {
      userCubit.fetchPaginatedUsers();
    }
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<UserCubit>().fetchNextPaginatedUsersPage();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger loading a bit before reaching the absolute bottom
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Paginated Users List')),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          final paginatedState = state.paginatedUsersState;

          if (paginatedState.status == DataStatus.loading && paginatedState.data.isEmpty) {
            return Center(child: CircularProgressIndicator());
          } else if (paginatedState.status == DataStatus.error && paginatedState.data.isEmpty) {
            return Center(child: Text('Error: ${paginatedState.errorMessage}'));
          } else if (paginatedState.data.isEmpty && paginatedState.status != DataStatus.loading) {
            return Center(child: Text('No users found.'));
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: paginatedState.data.length + (paginatedState.reachedMax ? 0 : 1),
            itemBuilder: (context, index) {
              if (index < paginatedState.data.length) {
                final user = paginatedState.data[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(user.id.toString())),
                  title: Text(user.name),
                );
              } else if (!paginatedState.reachedMax) {
                // Loader for next page
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return SizedBox.shrink(); // Should not happen if logic is correct
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

## API Reference

### `Fetcher.fetchWithBase<T>({required Future<DataState<T?>> Function() fetcher, required BaseState<T> state, required void Function(BaseState<T> newState) emitter, void Function(DataStatus status)? onStatusChange})`

Fetches a single item or a non-paginated list from an API and updates the state.

-   **`fetcher`**: A function that returns a `Future<DataState<T?>>` representing the API call. `T` is the type of the data item.
-   **`state`**: The current `BaseState<T>` that holds the data and status.
-   **`emitter`**: A function called to emit the new state updates. It receives the new `BaseState<T>`.
-   **`onStatusChange`** (optional): A callback function that is triggered whenever the `DataStatus` changes (e.g., `initial`, `loading`, `success`, `error`).

**Example Usage in a Cubit:**
```dart
Future<void> fetchItem() async {
  await Fetcher.fetchWithBase<MyItemType>(
    fetcher: () => myRepository.fetchItemDetails(), // Assuming this returns Future<DataState<MyItemType?>>
    state: state.itemDetailState, // e.g., state.itemDetailState is BaseState<MyItemType>
    emitter: (newState) => emit(state.copyWith(itemDetailState: newState)),
    onStatusChange: (status) => print('Item fetch status: $status'),
  );
}
```

### `Fetcher.fetchWithPaginate<T>({required Future<DataState<List<T>?>> Function(BaseQuery query) fetcher, required BasePaginationState<T> state, required void Function(BasePaginationState<T> newState) emitter, void Function(DataStatus status)? onStatusChange})`

Fetches a paginated list from an API and updates the state, handling page increments and data accumulation.

-   **`fetcher`**: A function that takes a `BaseQuery` (containing current page and size) and returns a `Future<DataState<List<T>?>>` representing the API call for a page. `T` is the type of items in the list.
-   **`state`**: The current `BasePaginationState<T>` that holds the list data, pagination status, and query parameters.
-   **`emitter`**: A function called to emit the new state updates. It receives the new `BasePaginationState<T>`.
-   **`onStatusChange`** (optional): A callback function for `DataStatus` changes (e.g., `initial`, `loading`, `paging`, `success`, `error`).

**Example Usage in a Cubit:**
```dart
Future<void> fetchItemsPage() async {
  await Fetcher.fetchWithPaginate<MyItemType>(
    fetcher: (query) => myRepository.fetchItemsPaginated(query), // Assuming this returns Future<DataState<List<MyItemType>?>>
    state: state.paginatedItemsState, // e.g., state.paginatedItemsState is BasePaginationState<MyItemType>
    emitter: (newState) => emit(state.copyWith(paginatedItemsState: newState)),
    onStatusChange: (status) => print('Paginated items fetch status: $status'),
  );
}

// To load the next page, simply call fetchItemsPage() again.
// The Fetcher will use the updated page number from state.paginatedItemsState.query.page.
void loadNextItemsPage() {
  if (!state.paginatedItemsState.reachedMax && state.paginatedItemsState.status != DataStatus.paging) {
    fetchItemsPage();
  }
}
```

## Contributing

Contributions are welcome! If you'd like to contribute, please follow these steps:

1.  Fork the repository on GitHub.
2.  Create a new branch for your feature or bug fix (`git checkout -b feature/your-feature-name` or `bugfix/issue-number`).
3.  Make your changes, ensuring your code adheres to the existing style and includes relevant tests.
4.  Commit your changes with clear, descriptive messages (`git commit -m 'feat: Add new feature that does X'`).
5.  Push your branch to your forked repository (`git push origin feature/your-feature-name`).
6.  Open a Pull Request to the main repository, detailing your changes.

Please ensure your code follows the package's coding style and includes appropriate tests where applicable.

## License

This package is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
