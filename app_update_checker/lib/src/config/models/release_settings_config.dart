import '../../models/text_translations.dart';
import '../../models/version.dart';

class ReleaseSettingsConfig {
  final TextTranslations? title;
  final TextTranslations? description;
  final bool? canIgnoreRelease;
  final Duration? reminderPeriod;
  final Duration? releaseDelay;
  final Version? deprecatedBeforeVersion;
  final Version? requiredMinimumVersion;
  final Map<String, dynamic>? customData;

  const ReleaseSettingsConfig({
    required this.title,
    required this.description,
    required this.canIgnoreRelease,
    required this.reminderPeriod,
    required this.releaseDelay,
    required this.deprecatedBeforeVersion,
    required this.requiredMinimumVersion,
    required this.customData,
  });
}
