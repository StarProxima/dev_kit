import '../../parser/sub_parsers/update_app_status_config/update_app_status_config.dart';
import 'mergeable.dart';

class UpdateAppStatusData extends UpdateAppStatusConfig with Mergeable {
  UpdateAppStatusData({
    required super.appStatus,
    required super.customData,
  });

  @override
  UpdateAppStatusData merge(covariant UpdateAppStatusData other) => UpdateAppStatusData(
        appStatus: other.appStatus,
        customData: mergeCustomData(customData, other.customData),
      );
}
