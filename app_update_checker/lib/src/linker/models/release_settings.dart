import 'dart:ui';

import '../../parser/models/release_settings_config.dart';
import '../../shared/text_translations.dart';
import '../../shared/version.dart';

class ReleaseSettings {
  final TextTranslations titleTranslations;
  final TextTranslations descriptionTranslations;
  final bool canIgnoreRelease;
  final Duration reminderPeriod;
  final Duration releaseDelay;
  final Version? deprecatedBeforeVersion;
  final Version? requiredMinimumVersion;
  final Map<String, dynamic>? customData;

  const ReleaseSettings({
    required this.titleTranslations,
    required this.descriptionTranslations,
    required this.canIgnoreRelease,
    required this.reminderPeriod,
    required this.releaseDelay,
    required this.deprecatedBeforeVersion,
    required this.requiredMinimumVersion,
    required this.customData,
  });

  factory ReleaseSettings.fromConfig(ReleaseSettingsConfig? config) {
    return ReleaseSettings(
      titleTranslations: config?.titleTranslations ?? {const Locale('en'): 'New update'}, // TODO подумать над дефолтным
      descriptionTranslations: config?.descriptionTranslations ?? {const Locale('en'): 'New update'},
      canIgnoreRelease: config?.canIgnoreRelease ?? true,
      reminderPeriod: config?.reminderPeriod ?? const Duration(days: 7),
      releaseDelay: config?.releaseDelay ?? Duration.zero,
      deprecatedBeforeVersion: config?.deprecatedBeforeVersion,
      requiredMinimumVersion: config?.requiredMinimumVersion,
      customData: config?.customData,
    );
  }
}
