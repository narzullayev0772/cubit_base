import 'package:cubit_base/src/base_state/base_pagination_state.dart';
import 'package:cubit_base/src/base_state/base_state.dart';
import 'package:cubit_base/src/base_state/data_state.dart';

class Fetcher {
  /// [fetch] is fetching function with base state
  ///
  /// Params:
  /// [fetcher] function that used with useCases
  /// [state] is target state, in fact input state
  /// [emitter] is emit, that will use for set,
  /// actually output state
  ///
  /// Example:
  ///
  /// ```dart
  /// Fetcher.fetchWithBase<T>(
  ///  fetcher: useCases.call(...),
  ///  state: state.<targetState>,
  ///  emitter: (newData) => emit(state.copyWith(<targetState>: newData)),
  ///  onStatusChange: (status) => print(status),
  ///  );
  ///  ```
  ///
  static Future<void> fetchWithBase<T>({
    required Future<DataState<T?>> fetcher,
    required BaseState<T> state,
    required void Function(BaseState<T> state) emitter,
    void Function(BaseStatus status)? onStatusChange,
  }) async {
    void onStatusChanged(BaseStatus status) {
      if (onStatusChange != null) {
        onStatusChange(status);
      }
    }

    onStatusChanged(BaseStatus.loading);
    BaseState<T> newState = state.copyWith(status: BaseStatus.loading);
    try {
      emitter(newState);

      final result = await fetcher;

      if (result is DataSuccess) {
        onStatusChanged(BaseStatus.success);
        newState = newState.copyWith(data: result.data, status: BaseStatus.success);
        emitter(newState);
      } else if (result is DataFailed) {
        onStatusChanged(BaseStatus.error);
        newState = newState.copyWith(errorMessage: result.errorMessage, status: BaseStatus.error);
        emitter(newState);
      }
    } catch (e) {
      onStatusChanged(BaseStatus.error);
      newState = newState.copyWith(errorMessage: e.toString(), status: BaseStatus.error);
      emitter(newState);
    } finally {
      onStatusChanged(BaseStatus.initial);
      newState = newState.copyWith(status: BaseStatus.initial);
      emitter(newState);
    }
  }

  static Future<void> fetchWithPaginate<T>({
    required Future<DataState<List<T>?>> fetcher,
    required BasePaginationState<T> state,
    required void Function(BasePaginationState<T> state) emitter,
    void Function(BasePaginationStatus status)? onStatusChange,
  }) async {
    if (state.query.page == 1) {
      await _fetchFirstPage<T>(fetcher: fetcher, state: state, emitter: emitter, onStatusChange: onStatusChange);
    } else {
      await _paginate<T>(fetcher: fetcher, state: state, emitter: emitter, onStatusChange: onStatusChange);
    }
  }

  static Future<void> _fetchFirstPage<T>({
    required Future<DataState<List<T>?>> fetcher,
    required BasePaginationState<T> state,
    required void Function(BasePaginationState<T> state) emitter,
    void Function(BasePaginationStatus status)? onStatusChange,
  }) async {
    void onStatusChanged(BasePaginationStatus status) {
      if (onStatusChange != null) {
        onStatusChange(status);
      }
    }

    onStatusChanged(BasePaginationStatus.loading);
    BasePaginationState<T> newState = state.copyWith(
      status: BasePaginationStatus.loading,
      query: state.query.copyWith(page: 1),
    );
    try {
      emitter(newState);
      final result = await fetcher;

      if (result is DataSuccess) {
        onStatusChanged(BasePaginationStatus.success);
        newState = newState.copyWith(
          list: result.data,
          status: BasePaginationStatus.success,
          reachedMax: (result.data?.length ?? 0) == state.query.size,
          query: state.query.copyWith(page: 2),
        );
        emitter(newState);
      } else if (result is DataFailed) {
        onStatusChanged(BasePaginationStatus.error);
        newState = newState.copyWith(errorMessage: result.errorMessage, status: BasePaginationStatus.error);
        emitter(newState);
      }
    } catch (e) {
      onStatusChanged(BasePaginationStatus.error);
      newState = newState.copyWith(errorMessage: e.toString(), status: BasePaginationStatus.error);
      emitter(newState);
    } finally {
      onStatusChanged(BasePaginationStatus.initial);
      newState = newState.copyWith(status: BasePaginationStatus.initial);
      emitter(newState);
    }
  }

  static Future<void> _paginate<T>({
    required Future<DataState<List<T>?>> fetcher,
    required BasePaginationState<T> state,
    required void Function(BasePaginationState<T> state) emitter,
    void Function(BasePaginationStatus status)? onStatusChange,
  }) async {
    if (state.status.isPaging || !state.reachedMax) return;
    void onStatusChanged(BasePaginationStatus status) {
      if (onStatusChange != null) {
        onStatusChange(status);
      }
    }

    onStatusChanged(BasePaginationStatus.paging);

    BasePaginationState<T> newState = state.copyWith(status: BasePaginationStatus.paging);

    try {
      emitter(newState);
      final result = await fetcher;

      if (result is DataSuccess) {
        onStatusChanged(BasePaginationStatus.success);
        newState = newState.copyWith(
          list: [...state.list, ...result.data ?? []],
          status: BasePaginationStatus.success,
          reachedMax: (result.data?.length ?? 0) == state.query.size,
          query: state.query.copyWith(page: state.query.page + 1),
        );
        emitter(newState);
      } else if (result is DataFailed) {
        onStatusChanged(BasePaginationStatus.error);
        newState = newState.copyWith(errorMessage: result.errorMessage, status: BasePaginationStatus.error);
        emitter(newState);
      }
    } catch (e) {
      onStatusChanged(BasePaginationStatus.error);
      newState = newState.copyWith(errorMessage: e.toString(), status: BasePaginationStatus.error);
      emitter(newState);
    } finally {
      onStatusChanged(BasePaginationStatus.initial);
      newState = newState.copyWith(status: BasePaginationStatus.initial);
      emitter(newState);
    }
  }
}
