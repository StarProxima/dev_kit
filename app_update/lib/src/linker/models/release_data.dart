import 'package:pub_semver/pub_semver.dart';

import '../../shared/update_status_wrapper.dart';
import '../../sources/source.dart';

class ReleaseData {
  final Version version;
  final Source targetSource;
  final DateTime? date;
  final UpdateSettingsDataContainer settings;
  final Map<String, dynamic>? customData;

  const ReleaseData({
    required this.version,
    required this.targetSource,
    required this.date,
    required this.settings,
    required this.customData,
  });
}
