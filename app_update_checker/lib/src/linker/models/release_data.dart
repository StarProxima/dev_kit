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
  final Map<String, dynamic>? customData;

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

  ReleaseData copyWith({
    Version? version,
    Version? refVersion,
    int? buildNumber,
    ReleaseStatus? status,
    String? title,
    TextTranslations? titleTranslations,
    String? description,
    TextTranslations? descriptionTranslations,
    String? releaseNote,
    TextTranslations? releaseNoteTranslations,
    DateTime? publishDateUtc,
    bool? canIgnoreRelease,
    Duration? reminderPeriod,
    Duration? releaseDelay,
    List<Store>? stores,
    Map<String, dynamic>? customData,
  }) {
    return ReleaseData(
      version: version ?? this.version,
      refVersion: refVersion ?? this.refVersion,
      buildNumber: buildNumber ?? this.buildNumber,
      status: status ?? this.status,
      titleTranslations: titleTranslations ?? this.titleTranslations,
      descriptionTranslations: descriptionTranslations ?? this.descriptionTranslations,
      releaseNoteTranslations: releaseNoteTranslations ?? this.releaseNoteTranslations,
      publishDateUtc: publishDateUtc ?? this.publishDateUtc,
      canIgnoreRelease: canIgnoreRelease ?? this.canIgnoreRelease,
      reminderPeriod: reminderPeriod ?? this.reminderPeriod,
      releaseDelay: releaseDelay ?? this.releaseDelay,
      stores: stores ?? this.stores,
      customData: customData ?? this.customData,
    );
  }
}
