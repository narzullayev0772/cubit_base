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
  String? errorMessage;

  BaseState({this.data, this.status = BaseStatus.initial, this.errorMessage});

  bool get hasData => data != null;

  bool get hasError => errorMessage != null;

  bool get noData => data == null;

  bool get noError => errorMessage == null;

  BaseState<T> copyWith({T? data, BaseStatus? status, String? errorMessage}) =>
      BaseState(
        data: data ?? this.data,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  factory BaseState.initial() => BaseState<T>();

  @override
  bool operator ==(Object other) {
    return other is BaseState &&
        other.data == data &&
        other.status == status &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => data.hashCode ^ status.hashCode ^ errorMessage.hashCode;
}
