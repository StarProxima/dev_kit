import 'package:pub_semver/pub_semver.dart';

import '../../shared/text_translations.dart';
import '../../shared/update_status_wrapper.dart';
import '../../sources/source.dart';

class ReleaseData {
  final Version version;
  final TextTranslations? releaseNoteTranslations;
  final DateTime? dateUtc;
  final UpdateSettings settings;
  final List<Source> sources;
  final Map<String, dynamic>? customData;

  const ReleaseData({
    required this.version,
    required this.releaseNoteTranslations,
    required this.dateUtc,
    required this.settings,
    required this.sources,
    required this.customData,
  });

  ReleaseData copyWith({
    Version? version,
    TextTranslations? releaseNoteTranslations,
    DateTime? dateUtc,
    UpdateSettings? settings,
    List<Source>? sources,
    Map<String, dynamic>? customData,
  }) {
    return ReleaseData(
      version: version ?? this.version,
      releaseNoteTranslations: releaseNoteTranslations ?? this.releaseNoteTranslations,
      dateUtc: dateUtc ?? this.dateUtc,
      settings: settings ?? this.settings,
      sources: sources ?? this.sources,
      customData: customData ?? this.customData,
    );
  }
}
