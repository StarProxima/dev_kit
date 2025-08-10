import '../../controller/exceptions.dart';
import '../../shared/models/update_search/update_search_data.dart';
import 'release.dart';
import 'update_config.dart';

class UpdateResponse {
  final UpdateSearchData searchData;
  final UpdateConfig config;
  final UpdateException? updateException;
  final Release? release;
  final Map<String, dynamic>? customData;

  bool get canUpdate => release != null && updateException == null;

  const UpdateResponse({
    required this.searchData,
    required this.config,
    required this.updateException,
    required this.release,
    required this.customData,
  });
}
