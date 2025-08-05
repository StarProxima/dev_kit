import 'package:pub_semver/pub_semver.dart';

import '../../sources/release_source.dart';
import 'update_settings.dart';
import 'update_texts.dart';

class Release {
  final Version version;
  final ReleaseSource source;
  final DateTime? date;
  final UpdateContent text;
  final UpdateSettings settings;
  final Map<String, dynamic>? customData;

  const Release({
    required this.version,
    required this.source,
    required this.date,
    required this.text,
    required this.settings,
    required this.customData,
  });
}
