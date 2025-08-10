import 'package:pub_semver/pub_semver.dart';

import '../../update_entities/update_platform.dart';
import '../../update_entities/update_source_name.dart';
import '../update_app_settings/update_app_settings_data.dart';
import '../update_content/update_content_data.dart';
import '../update_settings/update_settings_data.dart';

class Update {
  final Version version;
  final DateTime? date;
  final UpdateSourceName sourceName;
  final UpdatePlatform platform;
  final UpdateContentData content;
  final UpdateSettingsData settings;
  final UpdateAppSettingsData appSettings;
  final Map<String, dynamic>? customData;

  const Update({
    required this.version,
    required this.date,
    required this.sourceName,
    required this.platform,
    required this.content,
    required this.settings,
    required this.appSettings,
    required this.customData,
  });
}
