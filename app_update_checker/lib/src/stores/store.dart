import '../shared/update_platform.dart';

enum Stores {
  googlePlay,
  appStore,
  custom;

  factory Stores.parse(String name) => values.firstWhere(
        (e) => e.name == name,
        orElse: () => custom,
      );
}

class Store {
  final Stores store;
  final Uri url;
  final List<UpdatePlatform> platforms;
  final Map<String, dynamic>? customData;

  final String? _name;
  String get name => _name ?? store.name;

  factory Store({
    required String name,
    required Uri url,
    required List<UpdatePlatform>? platforms,
    required Map<String, dynamic>? customData,
  }) {
    switch (Stores.parse(name)) {
      case Stores.googlePlay:
        return Store.googlePlay(url: url, customData: customData);

      case Stores.appStore:
        return Store.appStore(url: url, customData: customData);

      case Stores.custom:
        return Store.custom(
          name: name,
          url: url,
          // TODO: Чекнуть, точно норм, что по дефолту на все платформы (в том числе web)?
          platforms: platforms ?? UpdatePlatform.values,
          customData: customData,
        );
    }
  }

  const Store.googlePlay({
    required this.url,
    this.customData,
  })  : store = Stores.googlePlay,
        platforms = const [UpdatePlatform.android],
        _name = null;

  const Store.appStore({
    required this.url,
    this.customData,
  })  : store = Stores.appStore,
        platforms = const [UpdatePlatform.ios, UpdatePlatform.macos],
        _name = null;

  const Store.custom({
    required String name,
    required this.url,
    required this.platforms,
    this.customData,
  })  : store = Stores.custom,
        _name = name;
}
