import '../../update_entities/app_status.dart';

class UpdateAppSettingsData {
  final AppStatus appStatus;
  final Map<String, dynamic>? customData;

  const UpdateAppSettingsData({
    required this.appStatus,
    required this.customData,
  });
}
