import 'package:pub_semver/pub_semver.dart';

import '../../entities/update_platform.dart';
import '../../entities/update_source_name.dart';
import '../update_app_settings/update_app_settings_data.dart';
import '../update_content/update_content_data.dart';
import '../update_settings/update_settings_data.dart';

class ReleaseData {
  final Version version;
  final DateTime date;
  final UpdateSourceName source;
  final UpdatePlatform platform;
  final UpdateContentData content;
  final UpdateSettingsData settings;
  final UpdateAppSettingsData appSettings;
  final Map<String, dynamic>? customParams;

  const ReleaseData({
    required this.version,
    required this.date,
    required this.source,
    required this.platform,
    required this.content,
    required this.settings,
    required this.appSettings,
    this.customParams,
  });
}
