abstract class AbstractBaseQuery {}

class BaseQuery extends AbstractBaseQuery{
  final int page;
  final int size;

  BaseQuery({required this.page, required this.size});

  BaseQuery copyWith({int? page, int? size}) =>
      BaseQuery(page: page ?? this.page, size: size ?? this.size);

  @override
  String toString() {
    return 'BaseQuery{page: $page, size: $size}';
  }

  @override
  bool operator ==(Object other) {
    return other is BaseQuery && page == other.page && size == other.size;
  }

  @override
  int get hashCode => page.hashCode ^ size.hashCode ;
}
