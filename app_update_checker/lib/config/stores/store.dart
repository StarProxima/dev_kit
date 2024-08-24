import 'default_store.dart';

part 'custom_store.dart';
part 'google_play.dart';

sealed class Store {
  const Store({
    required this.store,
    required this.url,
    required this.platforms,
  });

  final Stores store;
  final String url;
  final List<String> platforms;

  String get name => store.name;
}
