import '../release/update_data.dart';
import 'update_search_data.dart';

class UpdateSearchResult {
  final UpdateData? updateData;
  final UpdateData? localUpdateData;
  final UpdateSearchData searchData;

  const UpdateSearchResult({
    required this.updateData,
    required this.localUpdateData,
    required this.searchData,
  });
}
