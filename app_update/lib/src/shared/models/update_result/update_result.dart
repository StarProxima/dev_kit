import '../release/update.dart';
import '../update_status/update_status.dart';

class UpdateResult {
  final UpdateStatus updateStatus;
  final Update? update;
  final Map<String, dynamic> customData;

  const UpdateResult({
    required this.updateStatus,
    required this.update,
    required this.customData,
  });

  bool get shouldShow =>
      updateStatus.type == UpdateStatusType.available && (update?.settings.shouldShow ?? false);
}
