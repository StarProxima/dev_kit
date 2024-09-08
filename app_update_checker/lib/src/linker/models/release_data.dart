import '../../models/release_status.dart';
import '../../models/text_translations.dart';
import '../../models/version.dart';
import '../../stores/store.dart';

class ReleaseData {
  final Version version;
  final Version? refVersion;
  final int? buildNumber;
  final ReleaseStatus status;
  final TextTranslations titleTranslations;
  final TextTranslations descriptionTranslations;
  final TextTranslations? releaseNoteTranslations;
  final DateTime? publishDateUtc;
  final bool canIgnoreRelease;
  final Duration reminderPeriod;
  final Duration releaseDelay;
  final List<Store> stores;
  final Map<String, dynamic> customData;

  const ReleaseData({
    required this.version,
    required this.refVersion,
    required this.buildNumber,
    required this.status,
    required this.titleTranslations,
    required this.descriptionTranslations,
    required this.releaseNoteTranslations,
    required this.publishDateUtc,
    required this.canIgnoreRelease,
    required this.reminderPeriod,
    required this.releaseDelay,
    required this.stores,
    required this.customData,
  });
}
