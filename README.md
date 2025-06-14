# Cubit Base

`cubit_base` is a Flutter package designed to simplify state management for applications using the Cubit architecture (part of the BLoC pattern). It provides utilities to handle API data fetching and pagination with minimal boilerplate code, making it easier to manage asynchronous operations and state updates in your Flutter apps.

## Features

- **Simplified API Fetching**: Fetch data from APIs with built-in state management for loading, success, and error states.
- **Pagination Support**: Handle paginated data fetching with automatic page tracking and state updates.
- **Type-Safe State Management**: Works with generic types to support various data models (e.g., `UserModel`, `NotificationModel`).
- **Status Change Callbacks**: Optional callbacks to monitor state changes during fetching or pagination.
- **Reusable and Extensible**: Integrates seamlessly with Cubit and can be used with any use case or repository pattern.

## Installation

Add `cubit_base` to your `pubspec.yaml`:

```yaml
dependencies:
  cubit_base: ^[latest_version]
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

The `cubit_base` package provides two main methods in the `Fetcher` class:

1. **`fetchWithBase`**: For fetching single data items from an API.
2. **`fetchWithPaginate`**: For fetching paginated lists of data with automatic page handling.

### Key Components

- **BaseState<T>**: A base state class for managing single data fetching with statuses (`initial`, `loading`, `success`, `error`).
- **BasePaginationState<T>**: A state class for managing paginated data with additional pagination-specific statuses (`paging`) and properties like `reachedMax`.
- **DataState<T>**: A sealed class representing the result of an API call (`DataSuccess` or `DataFailed`).
- **Fetcher**: A utility class with static methods to handle fetching and pagination logic.

## Example

Below is an example demonstrating how to use `cubit_base` for both single data fetching and paginated data fetching.

### 1. Setting Up a Cubit

First, define your data model and Cubit. For this example, let's assume a `UserCubit` and a `UserState`.

#### `UserCubit`

```dart
// user_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:cubit_base/cubit_base.dart';

class UserCubit extends Cubit<UserState> {
  // or you can use with usecase
  final UserRepository repository;

  UserCubit(this.repository) : super(UserState.initial());

  Future<void> fetchUser(num userId) async {
    await Fetcher.fetchWithBase(
      fetcher: repository.getUser(userId), // getUserUseCase.call(params:userId);
      state: state.getUserState,
      emitter: (newState)=> emit(state.copyWith(getUserState: newState.data)),
      onStatusChange: (status) => print('Status: $status'),
    );
  }

  Future<void> fetchUsersList() async {
    await Fetcher.fetchWithBase(
      fetcher: repository.getUsersList(), // getUsersListUseCase.call(params:null);
      state: state.getUsersListState,
      emitter: (newState)=> emit(state.copyWith(getUsersListState: newState.data)),
      onStatusChange: (status) => print('Status: $status'),
    );
  }

  Future<void> fetchUsersListWithPaginate() async {
    await Fetcher.fetchWithPaginate(
      fetcher: repository.getUsersListWithPaginate(params:state.usersListState.query), // getUsersListUseCase.call(params:null);
      state: state.usersListState,
      emitter: (newState)=> emit(state.copyWith(usersListState: newState.data)),
      onStatusChange: (status) => print('Status: $status'),
    );
  }
}
```

#### `UserState`

```dart
// user_state.dart
class UserState{
  final BaseState<UserModel> getUserState;
  final BaseState<List<UserModel>> getUsersListState;
  final BasePaginationState<UserModel> usersListState;

  factory UserState.initial() => UserState(getUserState: BaseState.initial(), getUsersListState: BaseState.initial(), usersListState: BasePaginationState(query: BaseQuery(page: 1, size: 10)));

  @override
  UserState copyWith({
    BaseState<UserModel>? getUserState,
    BaseState<List<UserModel>>? getUsersListState,
    BasePaginationState<UserModel>? usersListState,
  }) {
    return UserState(
      getUserState: getUserState ?? this.getUserState,
      getUsersListState: getUsersListState ?? this.getUsersListState,
      usersListState: usersListState ?? this.usersListState,
    );
  }
}
```


### 2. Using `fetchWithBase`

Use `fetchWithBase` to fetch a single item, such as a user profile.

```dart
// Fetch a single user
userCubit.fetchUser(123);

// Fetch a list of users
userCubit.fetchUsersList();
```

This will:
- Set the state to `loading`.
- Call the repository's `getUser` method.
- Update the state to `success` with the fetched data or `error` with an error message.
- Reset the state to `initial` after completion.
- Trigger `onStatusChange` callbacks for each state change.

### 3. Using `fetchWithPaginate`

Use `fetchWithPaginate` to fetch paginated data, such as a list of users.

```dart

// Fetch a list of users with pagination
userCubit.fetchUsersListWithPaginate();
```

This will:
- For the first page (`page == 1`):
    - Set the state to `loading`.
    - Fetch the data and reset the list.
    - Update the state to `success` with the new list or `error` with an error message.
    - Set `reachedMax` based on the response size.
    - Increment the page number.
- For subsequent pages:
    - Check if pagination is allowed (`!reachedMax` and not already `paging`).
    - Set the state to `paging`.
    - Append new data to the existing list.
    - Update `reachedMax` and increment the page number.
- Reset the state to `initial` after completion.
- Trigger `onStatusChange` callbacks for each state change.

### 4. UI Integration

Integrate with your UI using a `BlocBuilder` to react to state changes.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ...,
      child: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          if (state.status.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state.status.isSuccess) {
            return ListView.builder(
              itemCount: state.list.length + (state.reachedMax ? 0 : 1),
              itemBuilder: (context, index) {
                if (index < state.list.length) {
                  return ListTile(title: Text(state.list[index].name));
                } else {
                  context.read<UserCubit>().fetchUsers();
                  return Center(child: CircularProgressIndicator());
                }
              },
            );
          } else if (state.status.isError) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }
          return Container();
        },
      ),
    );
  }
}
```

## API Reference

### `Fetcher.fetchWithBase<T>`

Fetches a single item from an API and updates the state.

**Parameters**:
- `fetcher`: A `Future<DataState<T?>>` representing the API call.
- `state`: The current `BaseState<T>` to update.
- `emitter`: A function to emit the new state.
- `onStatusChange`: An optional callback for status changes (`loading`, `success`, `error`, `initial`).

**Example**:
```dart
Fetcher.fetchWithBase<T>(
fetcher: useCases.call(...),
state: state.<targetState>,
emitter: (newData) => emit(state.copyWith(<targetState>: newData)),
onStatusChange: (status) => print(status),
);
```

### `Fetcher.fetchWithPaginate<T>`

Fetches a paginated list from an API and updates the state.

**Parameters**:
- `fetcher`: A `Future<DataState<List<T>?>>` representing the API call.
- `state`: The current `BasePaginationState<T>` to update.
- `emitter`: A function to emit the new state.
- `onStatusChange`: An optional callback for status changes (`loading`, `paging`, `success`, `error`, `initial`).

**Example**:
```dart
Fetcher.fetchWithBase<T>(
fetcher: useCases.call(...),
state: state.<targetState>,
emitter: (newData) => emit(state.copyWith(<targetState>: newData)),
onStatusChange: (status) => print(status),
);
```

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/YourFeature`).
3. Commit your changes (`git commit -m 'Add YourFeature'`).
4. Push to the branch (`git push origin feature/YourFeature`).
5. Open a Pull Request.

Please ensure your code follows the package's coding style and includes appropriate tests.

## License

This package is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
