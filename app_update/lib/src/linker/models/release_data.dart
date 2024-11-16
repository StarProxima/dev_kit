import 'package:pub_semver/pub_semver.dart';

import '../../sources/source.dart';
import 'update_settings_data_container.dart';
import 'update_text_data_container.dart';

class ReleaseData {
  final Version version;
  final Source source;
  final DateTime? date;
  final UpdateTextDataContainer text;
  final UpdateSettingsDataContainer settings;
  final Map<String, dynamic>? customData;

  const ReleaseData({
    required this.version,
    required this.source,
    required this.date,
    required this.text,
    required this.settings,
    required this.customData,
  });
}
