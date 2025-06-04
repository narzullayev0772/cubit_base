import 'package:cubit_base/cubit_base.dart';
import 'package:cubit_base/src/base_state/base_state.dart';
import 'package:cubit_base/src/base_state/data_state.dart';

void main() {
  Future<DataState<int>> fetcher = Future.value(DataSuccess(data: 42));
  BaseState<int> state = BaseState.initial();
  void emitter(BaseState<int> newState) {
    print('New state: ${newState.data}');
  }

  Fetcher.fetchWithBase(fetcher: fetcher, state: state, emitter: emitter);
}
