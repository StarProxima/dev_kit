part of 'store.dart';

class CustomStore extends Store {
  const CustomStore({
    required this.customName,
    required super.url,
    required super.platforms,
  }) : super(store: Stores.customStore);

  final String customName;

  @override
  String get name => customName;
}
