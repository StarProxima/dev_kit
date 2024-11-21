import 'package:pub_semver/pub_semver.dart';

import '../../sources/release_source.dart';
import 'update_container_storage.dart';
import 'update_settings_data_container.dart';
import 'update_text_data_container.dart';

class ReleaseData {
  final Version version;
  final ReleaseSource source;
  final DateTime? date;
  final UpdateContainerStorage<UpdateTextDataContainer> textContainers;
  final UpdateContainerStorage<UpdateSettingsDataContainer> settingsContainers;
  final Map<String, dynamic>? customData;

  const ReleaseData({
    required this.version,
    required this.source,
    required this.date,
    required this.textContainers,
    required this.settingsContainers,
    required this.customData,
  });
}
