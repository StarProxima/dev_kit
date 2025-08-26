library update_searcher_test;

import 'package:app_update/src/searcher/update_search_data_defaulter.dart';
import 'package:app_update/src/searcher/update_searcher.dart';
import 'package:app_update/src/searcher/update_source_support_checker.dart';
import 'package:app_update/src/shared/entities/update_platform.dart';
import 'package:app_update/src/shared/entities/update_source.dart';
import 'package:app_update/src/shared/entities/update_source_name.dart';
import 'package:app_update/src/shared/models/release/update_data.dart';
import 'package:app_update/src/shared/models/update_search/update_search_config.dart';
import 'package:app_update/src/shared/models/update_search/update_search_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

part 'groups/find_available_updates_test_group.dart';
part 'groups/find_current_test_group.dart';
part 'groups/find_relevant_test_group.dart';
part 'groups/search_full_test_group.dart';
part 'groups/sort_test_group.dart';
part 'helpers/test_utils.dart';

void main() {
  runFindAvailableUpdatesTests();
  runFindRelevantTests();
  runFindCurrentTests();
  runSortTests();
  runSearchFullTests();
}
