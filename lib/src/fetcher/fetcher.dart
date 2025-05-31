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

  /// fetch with pagination
  /// [fetchWithPaging] is fetching function with base paging state
  ///
  /// Params:
  /// [isPaging] is paging status
  /// [size] is size of data
  /// [targetState] is target state, in fact input state
  /// [emitter] is emit, that will use for set,
  /// actually output state
  /// [fetcher] function that used with useCases
  /// [shouldIncrement] is function that used for increment page
  ///
  /// Example:
  ///
  /// ```dart
  /// await Fetcher.fetchWithPaging(
  /// isPaging: isPaging,
  /// targetState: state.query,
  /// fetcher: _getNotificationHistoryUseCase.call(params: NotificationHistoryQuery(page: state.query.page, size: 3)),
  /// emitter: (newState) {
  /// emit(state.copyWith(query: newState, notificationHistory: newState.query));
  /// },
  /// );
  ///  ```
  // static Future<void> fetchWithPaging<T, Q>({
  //   bool isPaging = false,
  //   required BaseQuery<BasePagingState<T, Q>> targetState,
  //   required Future<DataState<List<T>?>> fetcher,
  //   required void Function(BaseQuery<BasePagingState<T, Q>> state) emitter,
  // }) async {
  //   if (!targetState.query.reachedMax || !isPaging) {
  //     targetState = targetState.copyWith(
  //       query: targetState.query.copyWith(
  //         list: isPaging ? targetState.query.list : [],
  //         status: isPaging ? BasePagingStatus.paging : BasePagingStatus.loading,
  //       ),
  //       page: isPaging ? targetState.page : 1,
  //     );
  //     emitter(targetState);
  //
  //     final dataState = await fetcher;
  //     if (dataState is DataSuccess) {
  //       final newList = dataState.data ?? [];
  //       targetState = targetState.copyWith(
  //         query: targetState.query.copyWith(
  //           status: BasePagingStatus.success,
  //           list: isPaging ? [...targetState.query.list, ...newList] : newList,
  //           reachedMax: (dataState.data?.length ?? 0) < targetState.size,
  //         ),
  //         page: targetState.page + 1,
  //       );
  //       emitter(targetState);
  //     } else if (dataState is DataFailed) {
  //       targetState = targetState.copyWith(
  //           query: targetState.query.copyWith(
  //         status: BasePagingStatus.error,
  //         error: dataState.message,
  //       ));
  //       emitter(targetState);
  //     }
  //     targetState = targetState.copyWith(query: targetState.query.copyWith(status: BasePagingStatus.initial));
  //     emitter(targetState);
  //   }
  // }

  /// fetch with custom
}

// class BaseQuery<Q extends BasePagingState> {
//   final int page;
//   final int size;
//   final Q query;
//
//   BaseQuery({
//     this.page = 1,
//     this.size = 15,
//     required this.query,
//   });
//
//   BaseQuery<Q> copyWith({
//     int? page,
//     int? size,
//     Q? query,
//   }) {
//     return BaseQuery<Q>(
//       page: page ?? this.page,
//       size: size ?? this.size,
//       query: query ?? this.query,
//     );
//   }
// }