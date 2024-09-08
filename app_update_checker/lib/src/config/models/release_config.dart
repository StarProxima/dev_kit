import '../../models/release_status.dart';
import '../../models/text_translations.dart';
import '../../models/version.dart';
import 'store_config.dart';

class ReleaseConfig {
  final Version version;
  final Version? refVersion;
  final int? buildNumber;
  final ReleaseStatus? status;
  final TextTranslations? titleTranslations;
  final TextTranslations? descriptionTranslations;
  final TextTranslations? releaseNoteTranslations;
  final DateTime? publishDateUtc;
  final bool? canIgnoreRelease;
  final Duration? reminderPeriod;
  final Duration? releaseDelay;
  final List<StoreConfig>? stores;
  final Map<String, dynamic>? customData;

  const ReleaseConfig({
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

  ReleaseConfig inherit(ReleaseConfig parent) {
    return ReleaseConfig(
      version: version,
      refVersion: refVersion,
      buildNumber: buildNumber,
      status: status ?? parent.status,
      titleTranslations: titleTranslations ?? parent.titleTranslations,
      descriptionTranslations: descriptionTranslations ?? parent.descriptionTranslations,
      releaseNoteTranslations: releaseNoteTranslations ?? parent.releaseNoteTranslations,
      publishDateUtc: publishDateUtc ?? parent.publishDateUtc,
      canIgnoreRelease: canIgnoreRelease ?? parent.canIgnoreRelease,
      reminderPeriod: reminderPeriod ?? parent.reminderPeriod,
      releaseDelay: releaseDelay ?? parent.releaseDelay,
      stores: stores ?? parent.stores,
      customData: customData ?? parent.customData,
    );
  }
}
