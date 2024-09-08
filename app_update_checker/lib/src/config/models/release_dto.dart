import '../../models/localized_text.dart';
import '../../models/release_status.dart';
import '../../models/version.dart';

import 'store_dto.dart';

class ReleaseDTO {
  final Version version;
  final Version? refVersion;
  final int? buildNumber;
  final ReleaseStatus? status;
  final LocalizedText? title;
  final LocalizedText? description;
  final LocalizedText? releaseNote;
  final DateTime? publishDateUtc;
  final bool? canIgnoreRelease;
  final Duration? reminderPeriod;
  final Duration? releaseDelay;
  final List<StoreDTO>? stores;
  final Map<String, dynamic> customData;

  const ReleaseDTO({
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

  ReleaseDTO inherit(ReleaseDTO parent) {
    return ReleaseDTO(
      version: version,
      refVersion: refVersion,
      buildNumber: buildNumber,
      status: status ?? parent.status,
      title: title ?? parent.title,
      description: description ?? parent.description,
      releaseNote: releaseNote ?? parent.releaseNote,
      publishDateUtc: publishDateUtc ?? parent.publishDateUtc,
      canIgnoreRelease: canIgnoreRelease ?? parent.canIgnoreRelease,
      reminderPeriod: reminderPeriod ?? parent.reminderPeriod,
      releaseDelay: releaseDelay ?? parent.releaseDelay,
      stores: stores ?? parent.stores,
      customData: customData.isNotEmpty ? customData : parent.customData,
    );
  }
}
