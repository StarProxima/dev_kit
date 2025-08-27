import '../../entities/app_status.dart';
import 'update_app_settings_config.dart';

class UpdateAppSettingsData {
  final AppStatus appStatus;
  final Map<String, dynamic>? customData;

  const UpdateAppSettingsData({
    required this.appStatus,
    required this.customData,
  });

  factory UpdateAppSettingsData.fromConfig(UpdateAppSettingsConfig config) {
    return UpdateAppSettingsData(
      appStatus:
          config.appStatus ?? (throw ArgumentError('appStatus is required')),
      customData: config.customData,
    );
  }
}
