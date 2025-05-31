abstract class DataState<T> {
  final T? data;
  final String? errorMessage;

  const DataState({this.data, this.errorMessage});
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess({required T super.data, super.errorMessage});
}

class DataFailed<T> extends DataState<T> {
  const DataFailed({required String super.errorMessage});
}
