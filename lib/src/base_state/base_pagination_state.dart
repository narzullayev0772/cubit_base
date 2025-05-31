import 'base_query.dart';

enum BasePaginationStatus { initial, loading, paging, success, error }

extension BasePaginationStatusService on BasePaginationStatus {
  bool get isInitial => this == BasePaginationStatus.initial;

  bool get isLoading => this == BasePaginationStatus.loading;

  bool get isPaging => this == BasePaginationStatus.paging;

  bool get isSuccess => this == BasePaginationStatus.success;

  bool get isError => this == BasePaginationStatus.error;
}

class BasePaginationState<T, Q> {
  List<T> list;
  BasePaginationStatus status;
  BaseQuery<Q> query;
  bool reachedMax;
  String? errorMessage;

  BasePaginationState({
    this.list = const [],
    this.status = BasePaginationStatus.initial,
    required this.query,
    this.reachedMax = false,
    this.errorMessage = 'Some Error',
  });

  BasePaginationState<T, Q> copyWith({
    List<T>? list,
    BaseQuery<Q>? query,
    BasePaginationStatus? status,
    bool? reachedMax,
    String? errorMessage,
  }) => BasePaginationState(
    list: list ?? this.list,
    query: query ?? this.query,
    status: status ?? this.status,
    reachedMax: reachedMax ?? this.reachedMax,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  factory BasePaginationState.initial() => BasePaginationState<T, Q>(list: [], query: BaseQuery.initial());
}
