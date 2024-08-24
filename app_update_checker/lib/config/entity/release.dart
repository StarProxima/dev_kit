import '../stores/store.dart';
import 'version.dart';

class Release {
  const Release({
    required this.version,
    required this.isActive,
    required this.isRequired,
    required this.isBroken,
    required this.title,
    required this.description,
    required this.releaseNote,
    required this.stores,
  });

  final Version version;
  final bool isActive;
  final bool isRequired;
  final bool isBroken;
  final Map<String, String> title;
  final Map<String, String> description;
  final Map<String, String> releaseNote;
  final List<Store> stores;
  // - googlePlay
  // - appStore
  // - ruStore
  // - store: github
  //   platforms:
  //     - android
  //     - ios
  //     - aurora
}
