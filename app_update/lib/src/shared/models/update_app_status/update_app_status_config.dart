import '../../mergeable.dart';
import '../../update_entities/app_status.dart';

class UpdateAppStatusConfig with Mergeable {
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

  @override
  UpdateAppStatusConfig merge(covariant UpdateAppStatusConfig other) =>
      UpdateAppStatusConfig.byRequired(
        appStatus: other.appStatus ?? appStatus,
        customData: mergeCustomData(customData, other.customData),
      );
}
