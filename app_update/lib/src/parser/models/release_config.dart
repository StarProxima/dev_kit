import 'package:pub_semver/pub_semver.dart';

import '../../shared/update_settings_container.dart';
import '../../shared/update_text_container.dart';
import 'source_config.dart';

class ReleaseConfig {
  final Version? version;
  final DateTime? date;
  final UpdateTextConfigContainer? text;
  final UpdateSettingsConfigContainer? settings;
  final List<ReleaseSourceConfig>? sources;
  final Map<String, dynamic>? customData;

  const ReleaseConfig({
    this.version,
    this.date,
    this.text,
    this.settings,
    this.sources,
    this.customData,
  });

  const ReleaseConfig.byRequired({
    required this.version,
    required this.date,
    required this.text,
    required this.settings,
    required this.sources,
    required this.customData,
  });
}
