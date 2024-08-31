import '../../entity/locale_textl.dart';
import '../../entity/release_type.dart';
import '../../entity/version.dart';

import 'store_dto.dart';

class ReleaseDTO {
  final Version version;
  final Version? refVersion;
  final int? buildNumber;
  final ReleaseType? type;
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
    required this.type,
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
