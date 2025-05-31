import 'package:cubit_base/cubit_base.dart';
import 'package:cubit_base/src/base_state/base_state.dart';
import 'package:cubit_base/src/base_state/data_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<DataState<List<int>>> fetcher(bool error) async {
    await Future.delayed(Duration(seconds: 2));
    if (error) return DataFailed(errorMessage: 'error');
    return DataSuccess(data: [1, 2, 3, 4]);
  }

  test('adds one to input values', () {
    BaseState<List<int>> state = BaseState<List<int>>(data: []);
    void emitter(BaseState<List<int>> state) {

    }
    Fetcher.fetchWithBase(
      fetcher: fetcher(false),
      state: state,
      emitter: emitter,
      onStatusChange: (status) {
        if (status == BaseStatus.loading) {
          expect(status, BaseStatus.loading);
        } else if (status == BaseStatus.success) {
          expect(status, BaseStatus.success);
          expect(state.data, [1, 2, 3,4]);
        }
      },
    );
  });
}
