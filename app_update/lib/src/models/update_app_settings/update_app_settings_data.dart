import '../../entities/app_status.dart';
import 'update_app_settings_config.dart';

class UpdateAppSettingsData {
  final AppStatus appStatus;
  final Map<String, dynamic>? customParams;

  const UpdateAppSettingsData({
    required this.appStatus,
    required this.customParams,
  });

  factory UpdateAppSettingsData.fromConfig(UpdateAppSettingsConfig config) {
    return UpdateAppSettingsData(
      appStatus:
          config.appStatus ?? (throw ArgumentError('appStatus is required')),
      customParams: config.customParams,
    );
  }
}
