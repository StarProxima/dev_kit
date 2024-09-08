import 'dart:ui';

import '../dto/models/release_settings_dto.dart';
import 'localized_text.dart';
import 'version.dart';

class ReleaseSettings {
  final LocalizedText title;
  final LocalizedText description;
  final bool canIgnoreRelease;
  final Duration reminderPeriod;
  final Duration releaseDelay;
  final Version? deprecatedBeforeVersion;
  final Version? requiredMinimumVersion;
  final Map<String, dynamic> customData;

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

  ReleaseSettings.fromDTO(ReleaseSettingsDTO dto)
      : title = dto.title ?? {const Locale('en'): 'New update'}, // TODO подумать над дефолтным
        description = dto.description ?? {const Locale('en'): 'New update'},
        canIgnoreRelease = dto.canIgnoreRelease ?? true,
        reminderPeriod = dto.reminderPeriod ?? const Duration(days: 7),
        releaseDelay = dto.releaseDelay ?? Duration.zero,
        deprecatedBeforeVersion = dto.deprecatedBeforeVersion,
        requiredMinimumVersion = dto.requiredMinimumVersion,
        customData = dto.customData;
}
