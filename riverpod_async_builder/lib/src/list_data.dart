class PaginatedListData<T> extends ListData<T> {
  const PaginatedListData({
    required super.index,
    required this.pageSize,
    required this.pointer,
    required this.indexOnPage,
    required this.itemsOnPage,
    required super.item,
  }) : super(
          indexOnPage: indexOnPage,
          items: itemsOnPage,
        );

  final int pageSize;
  final int pointer;
  final int indexOnPage;
  final List<T> itemsOnPage;
}

class ListData<T> {
  const ListData({
    required this.index,
    required List<T> items,
    required this.item,
    int? indexOnPage,
  })  : _index = indexOnPage ?? index,
        _items = items;

  final int index;
  final int _index;
  final List<T> _items;
  final T item;

  T? itemAt(int index) => index >= 0 ? _items.elementAtOrNull(index) : null;

  T? get prevItem => itemAt(_index - 1);
  T? get nextItem => itemAt(_index + 1);

  bool get isFirst => _index == 0;
  bool get isLast => _index == _items.length - 1;
}
