import 'package:pub_semver/pub_semver.dart';

import '../../shared/text_translations.dart';
import '../../shared/update_status_wrapper.dart';
import '../../sources/source.dart';

class ReleaseData {
  final Version version;
  final Source targetSource;
  // TODO нафига здесь это, если релизНоты есть в сеттингах сурсов?
  final TextTranslations? releaseNoteTranslations;
  final DateTime? dateUtc;
  final UpdateSettingsData? settings;
  final Map<String, dynamic>? customData;

  const ReleaseData({
    required this.version,
    required this.targetSource,
    required this.releaseNoteTranslations,
    required this.dateUtc,
    required this.settings,
    required this.customData,
  });
}
