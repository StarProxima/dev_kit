library update_rule_resolver_test;

import 'package:app_update/src/resolver/base/rule_matcher.dart';
import 'package:app_update/src/resolver/matchers/app_status_matcher.dart';
import 'package:app_update/src/resolver/matchers/custom_data_matcher.dart';
import 'package:app_update/src/resolver/matchers/locale_matcher.dart';
import 'package:app_update/src/resolver/matchers/source_matcher.dart';
import 'package:app_update/src/resolver/matchers/temporal_matcher.dart';
import 'package:app_update/src/resolver/matchers/version_matcher.dart';
import 'package:app_update/src/resolver/matchers/view_target_matcher.dart';
import 'package:app_update/src/resolver/update_rule_resolver.dart';
import 'package:app_update/src/shared/entities/app_status.dart';
import 'package:app_update/src/shared/entities/update_date.dart';
import 'package:app_update/src/shared/entities/update_locale.dart';
import 'package:app_update/src/shared/entities/update_platform.dart';
import 'package:app_update/src/shared/entities/update_source.dart';
import 'package:app_update/src/shared/entities/update_source_name.dart';
import 'package:app_update/src/shared/entities/update_version_constraint.dart';
import 'package:app_update/src/shared/entities/update_view_target.dart';
import 'package:app_update/src/shared/models/mergeable.dart';
import 'package:app_update/src/shared/models/update_content/update_content_config.dart';
import 'package:app_update/src/shared/models/update_rule/update_rule_config.dart';
import 'package:app_update/src/shared/models/update_search/update_search_data.dart';
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

void main() {
  runBasicResolverTests();
  runCustomDataMatchingTests();
  runInstallDateMatcherTests();
  runSourcesPlatformsMatchingTests();
  runTemporalMatchingTests();
}
