import 'dart:io';
import 'dart:ui';

import 'package:app_update/src/fetcher/source_fetchers/app_store_fetcher.dart';
import 'package:app_update/src/fetcher/source_fetchers/google_play_fetcher.dart';
import 'package:app_update/src/fetcher/source_fetchers/ru_store_fetcher.dart';
import 'package:app_update/src/fetcher/update_config_fetcher.dart';
import 'package:app_update/src/fetcher/update_config_fetcher_coordinator.dart';
import 'package:app_update/src/fetcher/update_config_source_fetcher.dart';
import 'package:app_update/src/parser/common.dart';
import 'package:app_update/src/parser/update_config_parser.dart';
import 'package:app_update/src/searcher/update_search_data_defaulter.dart';
import 'package:app_update/src/shared/entities/update_locale.dart';
import 'package:app_update/src/shared/entities/update_platform.dart';
import 'package:app_update/src/shared/entities/update_source.dart';
import 'package:app_update/src/shared/entities/update_source_name.dart';
import 'package:app_update/src/shared/entities/update_view_target.dart';
import 'package:app_update/src/shared/models/update/update_config.dart';
import 'package:app_update/src/shared/models/update_search/update_search_config.dart';
import 'package:app_update/src/shared/models/update_search/update_search_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

part 'groups/update_config_fetcher_coordinator_test_group.dart';
part 'groups/update_config_fetcher_test_group.dart';
part 'helpers/mock_source_fetchers.dart';

void main() {
  group('Fetcher', () {
    runUpdateConfigFetcherCoordinatorTests();
    runUpdateConfigFetcherTests();
  });
}
