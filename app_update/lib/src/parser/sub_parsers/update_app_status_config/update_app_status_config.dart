import '../../../shared/app_status.dart';

class UpdateAppStatusConfig {
  final AppStatus? appStatus;
  final Map<String, dynamic>? customData;

  const UpdateAppStatusConfig({
    this.appStatus,
    this.customData,
  });

  const UpdateAppStatusConfig.byRequired({
    required this.appStatus,
    required this.customData,
  });
}
