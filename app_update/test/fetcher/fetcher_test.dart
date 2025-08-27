import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';
import 'package:app_update/app_update.dart';

part 'groups/update_config_fetcher_coordinator_test_group.dart';
part 'groups/update_config_fetcher_test_group.dart';
part 'helpers/mock_source_fetchers.dart';

void main() {
  group('Fetcher', () {
    runUpdateConfigFetcherCoordinatorTests();
    runUpdateConfigFetcherTests();
  });
}
