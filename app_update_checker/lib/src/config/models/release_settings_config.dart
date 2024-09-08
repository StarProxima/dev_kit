import '../../models/localized_text.dart';
import '../../models/version.dart';

class ReleaseSettingsConfig {
  final LocalizedText? title;
  final LocalizedText? description;
  final bool? canIgnoreRelease;
  final Duration? reminderPeriod;
  final Duration? releaseDelay;
  final Version? deprecatedBeforeVersion;
  final Version? requiredMinimumVersion;
  final Map<String, dynamic> customData;

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
