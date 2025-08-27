import 'package:app_update/app_update.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

part 'helpers/install_date_matcher.dart';
part 'helpers/resolver_test_helpers.dart';
part 'groups/basic_resolver_test_group.dart';
part 'groups/custom_data_matching_test_group.dart';
part 'groups/install_date_matcher_test_group.dart';
part 'groups/sources_platforms_matching_test_group.dart';
part 'groups/temporal_matching_test_group.dart';

void runUpdateRuleResolverTests() {
  group('UpdateRuleResolver', () {
    runBasicResolverTests();
    runCustomDataMatchingTests();
    runInstallDateMatcherTests();
    runSourcesPlatformsMatchingTests();
    runTemporalMatchingTests();
  });
}
