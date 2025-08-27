import 'package:app_update/app_update.dart';

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
  group('Searcher', () {
    runFindAvailableUpdatesTests();
    runFindRelevantTests();
    runFindCurrentTests();
    runSortTests();
    runSearchFullTests();
  });
}
