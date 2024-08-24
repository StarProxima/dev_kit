part of 'store.dart';

class GooglePlayStore extends Store {
  const GooglePlayStore({required super.url})
      : super(store: Stores.googlePlay, platforms: const ['android']);
}
