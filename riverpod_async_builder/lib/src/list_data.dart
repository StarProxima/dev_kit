// Предоставляет доп. данные для элемента списка,
// которые могут пригодиться при построении виджета
class ListData<T> {
  const ListData({
    required this.index,
    required this.items,
    required this.item,
  });

  final int index;
  final List<T> items;
  final T item;

  T? itemAt(int index) => index >= 0 ? items.elementAtOrNull(index) : null;

  T? get prevItem => itemAt(index - 1);
  T? get nextItem => itemAt(index + 1);

  bool get isFirst => index == 0;
  bool get isLast => index == items.length - 1;
}

// Предоставляет доп. данные для элемента списка при пагинации,
// которые могут пригодиться при построении виджета
class PaginatedListData<T> {
  const PaginatedListData({
    required this.index,
    required this.pageSize,
    required this.pointer,
    required this.indexOnPage,
    required this.item,
    required this.itemsOnPage,
    required List<T>? Function() itemsOnPrevPageFn,
    required List<T>? Function() itemsOnNextPageFn,
  })  : _itemsOnPrevPageFn = itemsOnPrevPageFn,
        _itemsOnNextPageFn = itemsOnNextPageFn;

  final int index;
  final int pageSize;
  final int pointer;
  final int indexOnPage;
  final T item;
  final List<T> itemsOnPage;

  List<T>? get itemsOnPrevPage => _itemsOnPrevPageFn();
  List<T>? get itemsOnNextPage => _itemsOnNextPageFn();
  final List<T>? Function() _itemsOnPrevPageFn;
  final List<T>? Function() _itemsOnNextPageFn;

  // Учитывает только текущую страницу
  T? itemOnPageAt(int index) =>
      index >= 0 ? itemsOnPage.elementAtOrNull(index) : null;

  T? get prevItemOnPage => itemOnPageAt(indexOnPage - 1);
  T? get nextItemOnPage => itemOnPageAt(indexOnPage + 1);

  bool get isFirstOnPage => indexOnPage == 0;
  bool get isLastOnPage => indexOnPage == itemsOnPage.length - 1;

  // Учитывает предыдущую и следущую страницу, если они есть
  T? itemAt(int index) => switch (index) {
        _ when index < 0 && index > -pageSize =>
          itemsOnPrevPage?.elementAtOrNull(pageSize + index),
        _ when index >= 0 && index < pageSize =>
          itemsOnPage.elementAtOrNull(index),
        _ when index >= pageSize && index < 2 * pageSize =>
          itemsOnNextPage?.elementAtOrNull(index - pageSize),
        _ => throw RangeError.range(index, -pageSize + 1, 2 * pageSize - 1),
      };

  T? get prevItem => itemAt(indexOnPage - 1);
  T? get nextItem => itemAt(indexOnPage + 1);
}
