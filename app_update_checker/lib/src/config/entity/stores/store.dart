enum Stores {
  googlePlay,
  appStore,
  custom;

  factory Stores.fromString(String name) => values.firstWhere(
        (e) => e.name == name,
        orElse: () => custom,
      );
}

class Store {
  final Stores store;
  final Uri url;
  final List<String> platforms;

  final String? _name;
  String get name => _name ?? store.name;

  const Store.googlePlay({
    required this.url,
  })  : store = Stores.googlePlay,
        platforms = const ['android'],
        _name = null;

  const Store.appStore({
    required this.url,
  })  : store = Stores.appStore,
        platforms = const ['ios', 'macos'],
        _name = null;

  const Store.custom({
    required String name,
    required this.url,
    required this.platforms,
  })  : store = Stores.custom,
        _name = name;
}
