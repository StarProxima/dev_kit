import 'package:pub_semver/pub_semver.dart';

import '../../shared/update_status_wrapper.dart';
import '../../sources/source.dart';

class Release {
  final Version version;
  final Source targetSource;
  final DateTime? dateUtc;
  final UpdateSettings settings;
  final Map<String, dynamic>? customData;

  const Release({
    required this.version,
    required this.targetSource,
    required this.dateUtc,
    required this.settings,
    required this.customData,
  });
}
