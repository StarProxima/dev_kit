import 'groups/find_available_updates_test_group.dart';
import 'groups/find_current_test_group.dart';
import 'groups/find_relevant_test_group.dart';
import 'groups/search_full_test_group.dart';
import 'groups/sort_test_group.dart';

void main() {
  runFindAvailableUpdatesTests();
  runFindRelevantTests();
  runFindCurrentTests();
  runSortTests();
  runSearchFullTests();
}
