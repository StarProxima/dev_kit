import 'dart:ui';

import '../../config/models/release_settings_config.dart';
import '../../models/text_translations.dart';
import '../../models/version.dart';

class ReleaseSettings {
  final TextTranslations title;
  final TextTranslations description;
  final bool canIgnoreRelease;
  final Duration reminderPeriod;
  final Duration releaseDelay;
  final Version? deprecatedBeforeVersion;
  final Version? requiredMinimumVersion;
  final Map<String, dynamic>? customData;

  const ReleaseSettings({
    required this.title,
    required this.description,
    required this.canIgnoreRelease,
    required this.reminderPeriod,
    required this.releaseDelay,
    required this.deprecatedBeforeVersion,
    required this.requiredMinimumVersion,
    required this.customData,
  });

  factory ReleaseSettings.fromConfig(ReleaseSettingsConfig config) {
    return ReleaseSettings(
      title: config.title ?? {const Locale('en'): 'New update'}, // TODO подумать над дефолтным
      description: config.description ?? {const Locale('en'): 'New update'},
      canIgnoreRelease: config.canIgnoreRelease ?? true,
      reminderPeriod: config.reminderPeriod ?? const Duration(days: 7),
      releaseDelay: config.releaseDelay ?? Duration.zero,
      deprecatedBeforeVersion: config.deprecatedBeforeVersion,
      requiredMinimumVersion: config.requiredMinimumVersion,
      customData: config.customData,
    );
  }
}
