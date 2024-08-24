part of 'store.dart';

class AppStore extends Store {
  const AppStore({required super.url})
      : super(store: Stores.appStore, platforms: const ['ios', 'macos']);
}
