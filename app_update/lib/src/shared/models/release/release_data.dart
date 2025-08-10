import 'package:pub_semver/pub_semver.dart';

import '../../update_entities/update_source_name.dart';
import '../update_app_status/update_app_status_data.dart';
import '../update_content/update_content_data.dart';
import '../update_settings/update_settings_data.dart';

class ReleaseData {
  final Version version;
  final DateTime date;
  final UpdateSourceName source;
  final UpdateContentData content;
  final UpdateSettingsData settings;
  final UpdateAppStatusData appStatus;
  final Map<String, dynamic>? customData;

  const ReleaseData({
    required this.version,
    required this.date,
    required this.source,
    required this.content,
    required this.settings,
    required this.appStatus,
    this.customData,
  });
}
