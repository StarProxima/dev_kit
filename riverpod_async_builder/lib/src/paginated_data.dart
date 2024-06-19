class PaginatedData<T> {
  const PaginatedData({
    required this.index,
    required this.pageSize,
    required this.pointer,
    required this.indexOnPage,
    required this.itemsOnPage,
    required this.item,
  });

  final int index;
  final int pageSize;
  final int pointer;
  final int indexOnPage;
  final List<T> itemsOnPage;
  final T item;

  T? itemAt(int index) =>
      index >= 0 ? itemsOnPage.elementAtOrNull(index) : null;

  T? get prevItem => itemAt(indexOnPage - 1);
  T? get nextItem => itemAt(indexOnPage + 1);
}
