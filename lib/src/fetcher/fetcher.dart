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
}