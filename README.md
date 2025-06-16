# Cubit Base

`cubit_base` is a Flutter package designed to simplify state management for applications using the Cubit architecture (part of the BLoC pattern). It provides utilities to handle API data fetching and pagination with minimal boilerplate code, making it easier to manage asynchronous operations and state updates in your Flutter apps.

## Features

- **Simplified API Fetching**: Fetch data from APIs with built-in state management for loading, success, and error states.
- **Pagination Support**: Handle paginated data fetching with automatic page tracking and state updates.
- **Type-Safe State Management**: Works with generic types to support various data models (e.g., `UserModel`, `NotificationModel`).
- **Status Change Callbacks**: Optional callbacks to monitor state changes during fetching or pagination.
- **Reusable and Extensible**: Integrates seamlessly with Cubit and can be used with any use case or repository pattern.

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

First, define your data model and Cubit. For this example, let's assume a `SearchCubit` and a `SearchState`.

#### `SearchCubit`

```dart
// search_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:cubit_base/cubit_base.dart';

class SearchCubit extends Cubit<SearchState> {
  final FetchSuggestionsUseCase _fetchSuggestionsUseCase;
  final FetchComplexFilterUseCase _fetchComplexFilterUseCase;
  final SendSuggestionViewUseCase _sendSuggestionViewUseCase;

  SearchCubit(
    this._fetchSuggestionsUseCase,
    this._fetchComplexFilterUseCase,
    this._sendSuggestionViewUseCase,
  ) : super(SearchState.initial());

  void fetchSuggestions(String value) => Fetcher.fetchWithBase(
        fetcher: _fetchSuggestionsUseCase.call(params: SuggestSearchQuery(search: value)),
        state: state.suggestionsState,
        emitter: (newState) => emit(state.copyWith(suggestionsState: newState)),
      );

  void fetchDefaultQuery() => Fetcher.fetchWithBase(
        fetcher: _fetchComplexFilterUseCase.call(defaults: true),
        state: state.filterState,
        emitter: (newState) => emit(state.copyWith(filterState: newState)),
      );

  void fetchWithSearchQuery(String value) {
    if (value.trim().isEmpty) {
      fetchDefaultQuery();
    } else {
      Fetcher.fetchWithBase(
        fetcher: _fetchComplexFilterUseCase.call(params: value),
        state: state.filterState,
        emitter: (newState) => emit(state.copyWith(filterState: newState)),
      );
    }
  }

  void viewedSuggestion(num suggestionId) => Fetcher.fetchWithBase(
        fetcher: _sendSuggestionViewUseCase.call(params: SuggestionSendBody(id: suggestionId)),
        state: state.sendSuggestionState,
        emitter: (newState) => emit(state.copyWith(sendSuggestionState: newState)),
      );
}
```

#### `SearchState`

```dart
// search_state.dart
class SearchState {
  final BaseState<List<AiSuggestModel>> suggestionsState;
  final BaseState<ComplexFilterModel> filterState;
  final BaseState sendSuggestionState;

  SearchState({
    required this.suggestionsState,
    required this.filterState,
    required this.sendSuggestionState,
  });

  factory SearchState.initial() {
    return SearchState(
      suggestionsState: BaseState.initial(),
      filterState: BaseState.initial(),
      sendSuggestionState: BaseState.initial(),
    );
  }

  SearchState copyWith({
    BaseState<List<AiSuggestModel>>? suggestionsState,
    BaseState<ComplexFilterModel>? filterState,
    BaseState? sendSuggestionState,
  }) {
    return SearchState(
      suggestionsState: suggestionsState ?? this.suggestionsState,
      filterState: filterState ?? this.filterState,
      sendSuggestionState: sendSuggestionState ?? this.sendSuggestionState,
    );
  }
}
```


### 2. UI Integration

Integrate with your UI using a `BlocBuilder` to react to state changes.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ...,
      child: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
            // when loading
          if (state.suggestionsState.status.isLoading) {
            return Center(child: CircularProgressIndicator());
            // when error
          }else if (state.status.isError) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }
            // when success and initial
          return ListView.builder(
              itemCount: state.suggestionsState.data.length,
              itemBuilder: (context, index) {
                AiSuggestModel item = state.suggestionsState.data[index];
                return ListTile(title: Text(item.name));
              },
            );
        },
      ),
    );
  }
}
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
