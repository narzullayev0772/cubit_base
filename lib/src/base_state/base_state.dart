enum BaseStatus { initial, loading, success, error }

extension BaseStatusService on BaseStatus {
  bool get isInitial => this == BaseStatus.initial;

  bool get isLoading => this == BaseStatus.loading;

  bool get isSuccess => this == BaseStatus.success;

  bool get isError => this == BaseStatus.error;
}

class BaseState<T> {
  T? data;
  BaseStatus status;
  String? error;

  BaseState({this.data, this.status = BaseStatus.initial, this.error});

  bool get hasData => data != null;

  bool get hasError => error != null;

  bool get noData => data == null;

  bool get noError => error == null;

  BaseState<T> copyWith({T? data, BaseStatus? status, String? error}) =>
      BaseState(
        data: data ?? this.data,
        status: status ?? this.status,
        error: error ?? this.error,
      );

  factory BaseState.initial() => BaseState<T>();

  @override
  bool operator ==(Object other) {
    return other is BaseState &&
        other.data == data &&
        other.status == status &&
        other.error == error;
  }

  @override
  int get hashCode => data.hashCode ^ status.hashCode ^ error.hashCode;
}
