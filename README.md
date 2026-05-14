# cubit_base

A lightweight Flutter library to simplify data fetching and pagination using Bloc/Cubit. It provides standardized states and a `Fetcher` utility to reduce boilerplate in your Clean Architecture features.

## Features

- 🚀 **Standardized States**: `BaseState` and `BasePaginationState` for consistent UI handling.
- 🔄 **Simplified Fetching**: `Fetcher.fetchWithBase` handles loading, success, and error states automatically.
- 📑 **Built-in Pagination**: `Fetcher.fetchWithPaginate` manages page increments and "reached max" logic.
- 🏗️ **Clean Architecture Friendly**: Designed to work seamlessly with UseCases and DataStates.

## Installation

Add `cubit_base` to your `pubspec.yaml`:

```yaml
dependencies:
  cubit_base: ^0.0.5
```

## Usage

### 1. Simple Data Fetching

Define your state using `BaseState`:

```dart
class UserState {
  final BaseState<User> user;
  
  UserState({required this.user});
  
  UserState copyWith({BaseState<User>? user}) => UserState(user: user ?? this.user);
}
```

Use the `Fetcher` in your Cubit:

```dart
Future<void> getUser() async {
  await Fetcher.fetchWithBase<User>(
    fetcher: () => _getUserUseCase.call(),
    state: state.user,
    emitter: (newState) => emit(state.copyWith(user: newState)),
  );
}
```

### 2. Pagination

Define your state using `BasePaginationState`:

```dart
class ProductState {
  final BasePaginationState<Product> products;

  ProductState({required this.products});

  ProductState copyWith({BasePaginationState<Product>? products}) =>
      ProductState(products: products ?? this.products);
}
```

Implement pagination in your Cubit:

```dart
Future<void> getProducts({bool isRefresh = false}) async {
  await Fetcher.fetchWithPaginate<Product>(
    fetcher: () => _getProductsUseCase.call(
      params: ProductParams(
        page: isRefresh ? 1 : state.products.query.page,
        size: state.products.query.size,
      ),
    ),
    state: state.products,
    isRefresh: isRefresh,
    emitter: (newState) => emit(state.copyWith(products: newState)),
  );
}
```

## State Components

### `BaseState<T>`
Manages a single object of type `T`.
- `status`: `initial`, `loading`, `success`, `error`.
- `data`: The fetched object.
- `error`: Error message if any.

### `BasePaginationState<T>`
Manages a list of type `T`.
- `list`: List of items.
- `status`: `initial`, `loading`, `paging`, `success`, `error`.
- `query`: Contains `page` and `size`.
- `reachedMax`: Boolean indicating if all data is loaded.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
