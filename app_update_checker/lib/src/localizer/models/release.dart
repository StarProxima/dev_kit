import '../../linker/models/release_data.dart';
import '../../shared/release_status.dart';
import '../../shared/text_translations.dart';
import '../../shared/version.dart';
import '../../stores/store.dart';

class Release extends ReleaseData {
  final String title;
  final String description;
  final String? releaseNote;

  const Release({
    required super.version,
    required super.refVersion,
    required super.buildNumber,
    required super.status,
    required this.title,
    required super.titleTranslations,
    required this.description,
    required super.descriptionTranslations,
    required this.releaseNote,
    required super.releaseNoteTranslations,
    required super.publishDateUtc,
    required super.canIgnoreRelease,
    required super.reminderPeriod,
    required super.releaseDelay,
    required super.stores,
    required super.customData,
  });

  @override
  Release copyWith({
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
    return Release(
      version: version ?? this.version,
      refVersion: refVersion ?? this.refVersion,
      buildNumber: buildNumber ?? this.buildNumber,
      status: status ?? this.status,
      title: title ?? this.title,
      titleTranslations: titleTranslations ?? this.titleTranslations,
      description: description ?? this.description,
      descriptionTranslations: descriptionTranslations ?? this.descriptionTranslations,
      releaseNote: releaseNote ?? this.releaseNote,
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
