import 'package:cubit_base/cubit_base.dart';
import 'package:cubit_base/src/base_state/base_pagination_state.dart';
import 'package:cubit_base/src/base_state/base_query.dart';
import 'package:cubit_base/src/base_state/base_state.dart';
import 'package:cubit_base/src/base_state/data_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fetchWithBase', () {
    test('emits loading → success → initial', () async {
      final emittedStates = <BaseState<String>>[];

      await Fetcher.fetchWithBase<String>(
        fetcher: Future.value(DataSuccess(data: "Hello world")),
        state: BaseState<String>(),
        emitter: (state) => emittedStates.add(state),
      );

      expect(emittedStates, [
        BaseState<String>(status: BaseStatus.loading),
        BaseState<String>(status: BaseStatus.success, data: "Hello world"),
        BaseState<String>(status: BaseStatus.initial, data: "Hello world"),
      ]);
    });

    test('emits loading → error → initial', () async {
      final emittedStates = <BaseState<String>>[];

      await Fetcher.fetchWithBase<String>(
        fetcher: Future.value(DataFailed(errorMessage: "Something went wrong")),
        state: BaseState<String>(),
        emitter: (state) => emittedStates.add(state),
      );

      expect(emittedStates, [
        BaseState<String>(status: BaseStatus.loading),
        BaseState<String>(status: BaseStatus.error, errorMessage: "Something went wrong"),
        BaseState<String>(status: BaseStatus.initial, errorMessage: "Something went wrong"),
      ]);
    });

    test('emits loading → error → initial on exception', () async {
      final emittedStates = <BaseState<String>>[];

      await Fetcher.fetchWithBase<String>(
        fetcher: Future<DataState<String>>.error(Exception('Failed')).catchError((e) => throw e),
        state: BaseState<String>(),
        emitter: (state) => emittedStates.add(state),
      );

      expect(emittedStates[0].status, BaseStatus.loading);
      expect(emittedStates[1].status, BaseStatus.error);
      expect(emittedStates[1].errorMessage, contains('Exception'));
      expect(emittedStates.last.status, BaseStatus.initial);
    });
  });

  group('fetchWithPaginate', () {
    test('fetch', () async {
      final emittedStates = <BasePaginationState<String>>[];
      final fetcher = Future.value(DataSuccess(data: ["Hello", "world"]));

      var state = BasePaginationState<String>(list: ["Hello"], query: BaseQuery(page: 1, size: 10));
      await Fetcher.fetchWithPaginate<String>(
        fetcher: fetcher,
        state: state,
        emitter: (newState) {
          state = newState;
          emittedStates.add(newState);
        },
      );
      expect(emittedStates, [
        BasePaginationState<String>(
          status: BasePaginationStatus.loading,
          list: ["Hello"],
          query: BaseQuery(page: 1, size: 10),
        ),
        BasePaginationState<String>(
          status: BasePaginationStatus.success,
          list: ["Hello", "world"],
          query: BaseQuery(page: 2, size: 10),
        ),
        BasePaginationState<String>(
          status: BasePaginationStatus.initial,
          list: ["Hello", "world"],
          query: BaseQuery(page: 2, size: 10),
        ),
      ]);
    });
    test('paginate', () async {
      final emittedStates = <BasePaginationState<String>>[];
      final fetcher = Future.value(DataSuccess(data: ["Hello", "world"]));

      var state = BasePaginationState<String>(list: ["Hello"], query: BaseQuery(page: 2, size: 10), reachedMax: true);
      await Fetcher.fetchWithPaginate<String>(
        fetcher: fetcher,
        state: state,
        emitter: (newState) {
          state = newState;
          emittedStates.add(newState);
        },
      );
      expect(emittedStates, [
        BasePaginationState<String>(
          status: BasePaginationStatus.paging,
          list: ["Hello"],
          query: BaseQuery(page: 2, size: 10),
          reachedMax: true,
        ),
        BasePaginationState<String>(
          status: BasePaginationStatus.success,
          list: ["Hello", "Hello", "world"],
          query: BaseQuery(page: 3, size: 10),
        ),
        BasePaginationState<String>(
          status: BasePaginationStatus.initial,
          list: ["Hello", "Hello", "world"],
          query: BaseQuery(page: 3, size: 10),
        ),
      ]);
    });
  });
}
