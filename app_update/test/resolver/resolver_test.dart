import 'package:app_update/app_update.dart';

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
