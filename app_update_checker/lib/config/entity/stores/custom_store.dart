part of 'store.dart';

class CustomStore extends Store {
  final String _name;

  @override
  // ignore: avoid-unnecessary-getter
  String get name => _name;

  const CustomStore({
    required String name,
    required super.url,
    required super.platforms,
  })  : _name = name,
        super(store: Stores.custom);
}
