abstract class DataState<T> {
  final T? data;
  final String? error;

  const DataState({this.data, this.error});
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess({required T super.data, super.error});
}

class DataFailed<T> extends DataState<T> {
  const DataFailed({required String super.error});
}
