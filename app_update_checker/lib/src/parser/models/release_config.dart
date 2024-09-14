import 'package:pub_semver/pub_semver.dart';

import '../../shared/text_translations.dart';
import '../../shared/update_status_wrapper.dart';
import 'release_settings_config.dart';
import 'store_config.dart';

class ReleaseConfig {
  final Version version;
  final DateTime? dateUtc;
  final UpdateStatusWrapper<TextTranslations?>? releaseNoteTranslations;
  final UpdateStatusWrapper<ReleaseSettingsConfig?>? releaseSettings;
  final List<SourceConfig>? sources;
  final Map<String, dynamic>? customData;

  const ReleaseConfig({
    required this.version,
    required this.dateUtc,
    required this.releaseNoteTranslations,
    required this.releaseSettings,
    required this.sources,
    required this.customData,
  });

  ReleaseConfig inherit(ReleaseConfig parent) {
    return ReleaseConfig(
      version: version,
      dateUtc: dateUtc ?? parent.dateUtc,
      releaseNoteTranslations: releaseNoteTranslations ?? parent.releaseNoteTranslations,
      releaseSettings: releaseSettings ?? parent.releaseSettings,
      sources: sources ?? parent.sources,
      customData: customData ?? parent.customData,
    );
  }
}
