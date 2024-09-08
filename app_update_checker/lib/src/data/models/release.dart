import '../../models/localized_text.dart';
import '../../models/release_status.dart';
import '../stores/store.dart';
import '../../models/version.dart';

class Release {
  final Version version;
  final Version? refVersion;
  final int? buildNumber;
  final ReleaseStatus status;
  final LocalizedText title;
  final LocalizedText description;
  final LocalizedText? releaseNote;
  final DateTime? publishDateUtc;
  final bool canIgnoreRelease;
  final Duration reminderPeriod;
  final Duration releaseDelay;
  final List<Store> stores;
  final Map<String, dynamic> customData;

  const Release({
    required this.version,
    required this.refVersion,
    required this.buildNumber,
    required this.status,
    required this.title,
    required this.description,
    required this.releaseNote,
    required this.publishDateUtc,
    required this.canIgnoreRelease,
    required this.reminderPeriod,
    required this.releaseDelay,
    required this.stores,
    required this.customData,
  });
}
