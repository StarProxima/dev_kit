import '../mergeable.dart';
import '../../update_entities/app_status.dart';

class UpdateAppSettingsConfig implements Mergeable {
  final AppStatus? appStatus;
  final Map<String, dynamic>? customData;

  const UpdateAppSettingsConfig({
    this.appStatus,
    this.customData,
  });

  const UpdateAppSettingsConfig.byRequired({
    required this.appStatus,
    required this.customData,
  });

  @override
  UpdateAppSettingsConfig merge(covariant UpdateAppSettingsConfig other) =>
      UpdateAppSettingsConfig.byRequired(
        appStatus: other.appStatus ?? appStatus,
        customData: Mergeable.mergeCustomData(customData, other.customData),
      );
}
