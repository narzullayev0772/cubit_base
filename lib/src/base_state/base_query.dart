abstract class AbstractBaseQuery<Q> {}

class BaseQuery<Q> extends AbstractBaseQuery<Q> {
  final int page;
  final int size;
  final Q query;

  BaseQuery({required this.query, required this.page, required this.size});

  static initial() {
    return BaseQuery(query: null, page: 1, size: 10);
  }

  BaseQuery<Q> copyWith({int? page, int? size, Q? query}) =>
      BaseQuery(query: query ?? this.query, page: page ?? this.page, size: size ?? this.size);
}
