import '../../models/text_translations.dart';
import '../../models/version.dart';

class ReleaseSettingsConfig {
  final TextTranslations? titleTranslations;
  final TextTranslations? descriptionTranslations;
  final bool? canIgnoreRelease;
  final Duration? reminderPeriod;
  final Duration? releaseDelay;
  final Version? deprecatedBeforeVersion;
  final Version? requiredMinimumVersion;
  final Map<String, dynamic>? customData;

  const ReleaseSettingsConfig({
    required this.titleTranslations,
    required this.descriptionTranslations,
    required this.canIgnoreRelease,
    required this.reminderPeriod,
    required this.releaseDelay,
    required this.deprecatedBeforeVersion,
    required this.requiredMinimumVersion,
    required this.customData,
  });
}
