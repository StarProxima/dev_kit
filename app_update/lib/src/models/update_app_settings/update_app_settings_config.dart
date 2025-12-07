import '../../entities/app_status.dart';
import '../../utils/mergeable.dart';

class UpdateAppSettingsConfig implements Mergeable<UpdateAppSettingsConfig> {
  final AppStatus? appStatus;
  final Map<String, dynamic>? customParams;

  const UpdateAppSettingsConfig({
    this.appStatus,
    this.customParams,
  });

  const UpdateAppSettingsConfig.byRequired({
    required this.appStatus,
    required this.customParams,
  });

  @override
  UpdateAppSettingsConfig merge(covariant UpdateAppSettingsConfig other) =>
      UpdateAppSettingsConfig.byRequired(
        appStatus: other.appStatus ?? appStatus,
        customParams:
            Mergeable.mergeCustomParams(customParams, other.customParams),
      );
}
