import '../../update_entities/app_status.dart';

class UpdateAppStatusData {
  final AppStatus appStatus;
  final Map<String, dynamic>? customData;

  const UpdateAppStatusData({
    required this.appStatus,
    required this.customData,
  });
}
