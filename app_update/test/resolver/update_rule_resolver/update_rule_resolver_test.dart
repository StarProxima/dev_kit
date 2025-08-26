import 'groups/basic_resolver_test_group.dart';
import 'groups/custom_data_matching_test_group.dart';
import 'groups/install_date_matcher_test_group.dart';
import 'groups/sources_platforms_matching_test_group.dart';
import 'groups/temporal_matching_test_group.dart';

void main() {
  runBasicResolverTests();
  runCustomDataMatchingTests();
  runInstallDateMatcherTests();
  runSourcesPlatformsMatchingTests();
  runTemporalMatchingTests();
}
