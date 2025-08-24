import '../release/update.dart';
import '../update_status/update_status.dart';

class UpdateResult {
  final UpdateStatus updateStatus;
  final Update? update;

  const UpdateResult({
    required this.updateStatus,
    required this.update,
  });

  bool get shouldShow =>
      updateStatus.type == UpdateStatusType.available && (update?.settings.shouldShow ?? false);
}
