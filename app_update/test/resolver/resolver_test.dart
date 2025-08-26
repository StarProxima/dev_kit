library resolver_test;

import 'package:app_update/src/resolver/update_content_interpolator.dart';
import 'package:app_update/src/resolver/update_resolver.dart';
import 'package:app_update/src/resolver/update_rule_resolver.dart';
import 'package:app_update/src/shared/entities/app_status.dart';
import 'package:app_update/src/shared/entities/update_locale.dart';
import 'package:app_update/src/shared/entities/update_platform.dart';
import 'package:app_update/src/shared/entities/update_source.dart';
import 'package:app_update/src/shared/entities/update_source_name.dart';
import 'package:app_update/src/shared/entities/update_view_target.dart';
import 'package:app_update/src/shared/models/release/update_data.dart';
import 'package:app_update/src/shared/models/update_app_settings/update_app_settings_config.dart';
import 'package:app_update/src/shared/models/update_content/update_content_config.dart';
import 'package:app_update/src/shared/models/update_content/update_content_data.dart';
import 'package:app_update/src/shared/models/update_result/update_result.dart';
import 'package:app_update/src/shared/models/update_rule/update_rule_config.dart';
import 'package:app_update/src/shared/models/update_search/update_search_data.dart';
import 'package:app_update/src/shared/models/update_settings/update_settings_config.dart';
import 'package:app_update/src/shared/models/update_status/update_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pub_semver/pub_semver.dart';
import 'groups/update_rule_resolver/rule_resolver_test_group.dart';

part 'groups/update_content_interpolator_test_group.dart';
part 'groups/update_resolver_test_group.dart';

void main() {
  group('Resolver', () {
    runUpdateContentInterpolatorTests();
    runUpdateResolverTests();
    runUpdateRuleResolverTests();
  });
}
