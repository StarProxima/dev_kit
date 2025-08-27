import 'package:app_update/app_update.dart';

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

part 'groups/global_platform_config_parser_test_group.dart';
part 'groups/global_source_config_parser_test_group.dart';
part 'groups/release_config_parser_test_group.dart';
part 'groups/release_platform_config_parser_test_group.dart';
part 'groups/release_source_config_parser_test_group.dart';
part 'groups/update_app_status_config_parser_test_group.dart';
part 'groups/update_content_config_parser_test_group.dart';
part 'groups/update_rule_config_parser_test_group.dart';
part 'groups/update_settings_config_parser_test_group.dart';
part 'groups/update_config_parser_integration_test_group.dart';

void main() {
  group('Parser', () {
    runGlobalPlatformConfigParserTests();
    runGlobalSourceConfigParserTests();
    runReleaseConfigParserTests();
    runReleasePlatformConfigParserTests();
    runReleaseSourceConfigParserTests();
    runUpdateAppStatusConfigParserTests();
    runUpdateContentConfigParserTests();
    runUpdateRuleConfigParserTests();
    runUpdateSettingsConfigParserTests();
    runUpdateConfigParserIntegrationTests();
  });
}
