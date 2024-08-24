part of 'store.dart';

class GooglePlay extends Store {
  const GooglePlay({required super.url})
      : super(store: Stores.googlePlay, platforms: const ['android']);
}
