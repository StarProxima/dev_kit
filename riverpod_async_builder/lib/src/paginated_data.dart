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

  T? get prevItem =>
      indexOnPage > 0 ? itemsOnPage.elementAtOrNull(indexOnPage - 1) : null;
  T? get nextItem => itemsOnPage.elementAtOrNull(indexOnPage + 1);
}
