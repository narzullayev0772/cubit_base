import 'package:flutter/foundation.dart';

import 'base_query.dart';

enum BasePaginationStatus { initial, loading, paging, success, error }

extension BasePaginationStatusService on BasePaginationStatus {
  bool get isInitial => this == BasePaginationStatus.initial;

  bool get isLoading => this == BasePaginationStatus.loading;

  bool get isPaging => this == BasePaginationStatus.paging;

  bool get isSuccess => this == BasePaginationStatus.success;

  bool get isError => this == BasePaginationStatus.error;
}

class BasePaginationState<T> {
  List<T> list;
  BasePaginationStatus status;
  BaseQuery query;
  bool reachedMax;
  String? errorMessage;

  BasePaginationState({
    this.list = const [],
    this.status = BasePaginationStatus.initial,
    required this.query,
    this.reachedMax = false,
    this.errorMessage,
  });

  BasePaginationState<T> copyWith({
    List<T>? list,
    BaseQuery? query,
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

  @override
  String toString() {
    return 'BasePaginationState{list: $list, status: $status, query: $query, reachedMax: $reachedMax, errorMessage: $errorMessage}';
  }

  @override
  bool operator ==(Object other) {
    return other is BasePaginationState &&
        listEquals(list, other.list) &&
        status == other.status &&
        query == other.query &&
        reachedMax == other.reachedMax &&
        errorMessage == other.errorMessage;
  }

  @override
  int get hashCode {
    return list.hashCode ^ status.hashCode ^ query.hashCode ^ reachedMax.hashCode ^ errorMessage.hashCode;
  }
}
