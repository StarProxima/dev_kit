import 'package:pub_semver/pub_semver.dart';

import '../../shared/update_settings_container.dart';
import '../../sources/source.dart';

class Release {
  final Version version;
  final Source source;
  final DateTime? date;
  final UpdateSettingsContainer settings;
  final Map<String, dynamic>? customData;

  const Release({
    required this.version,
    required this.source,
    required this.date,
    required this.settings,
    required this.customData,
  });
}
