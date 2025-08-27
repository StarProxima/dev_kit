import '../release/update.dart';
import '../update_search/update_search_data.dart';
import '../update_status/update_status.dart';

class UpdateResult {
  final UpdateStatus updateStatus;
  final UpdateSearchData? searchData;
  final Update? update;

  const UpdateResult({
    required this.updateStatus,
    required this.searchData,
    required this.update,
  });

  bool get shouldShow =>
      updateStatus.type == UpdateStatusType.found &&
      (update?.settings.shouldShow ?? false);
}
