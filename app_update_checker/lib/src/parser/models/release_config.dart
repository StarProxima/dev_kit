import 'package:pub_semver/pub_semver.dart';

import '../../shared/text_translations.dart';
import '../../shared/update_status_wrapper.dart';
import 'source_config.dart';

class ReleaseConfig {
  final Version version;
  final DateTime? dateUtc;
  final TextTranslations? releaseNoteTranslations;
  final UpdateSettingsConfig? settings;
  final List<ReleaseSourceConfig>? sources;
  final Map<String, dynamic>? customData;

  const ReleaseConfig({
    required this.version,
    required this.dateUtc,
    required this.releaseNoteTranslations,
    required this.settings,
    required this.sources,
    required this.customData,
  });
}
