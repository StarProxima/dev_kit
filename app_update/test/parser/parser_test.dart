library parser_test;

import 'dart:io';
import 'package:app_update/src/parser/common.dart';
import 'package:app_update/src/parser/sub_parsers/global_platform_config_parser.dart';
import 'package:app_update/src/parser/sub_parsers/global_source_config_parser.dart';
import 'package:app_update/src/parser/sub_parsers/release_config_parser.dart';
import 'package:app_update/src/parser/sub_parsers/release_platrform_config_parser.dart';
import 'package:app_update/src/parser/sub_parsers/release_source_config_parser.dart';
import 'package:app_update/src/parser/sub_parsers/update_app_settings_config_parser.dart';
import 'package:app_update/src/parser/sub_parsers/update_content_config_parser.dart';
import 'package:app_update/src/parser/sub_parsers/update_rule_config_parser.dart';
import 'package:app_update/src/parser/sub_parsers/update_settings_config_parser.dart';
import 'package:app_update/src/parser/update_config_parser.dart';
import 'package:app_update/src/shared/models/global_platform/global_platform_config.dart';
import 'package:app_update/src/shared/models/global_source/global_source_config.dart';
import 'package:app_update/src/shared/models/mergeable.dart';
import 'package:app_update/src/shared/models/release/release_config.dart';
import 'package:app_update/src/shared/models/release_platrform/release_platrform_config.dart';
import 'package:app_update/src/shared/models/release_source/release_source_config.dart';
import 'package:app_update/src/shared/models/update/update_config.dart';
import 'package:app_update/src/shared/models/update_app_settings/update_app_settings_config.dart';
import 'package:app_update/src/shared/models/update_content/update_content_config.dart';
import 'package:app_update/src/shared/models/update_rule/update_rule_config.dart';
import 'package:app_update/src/shared/models/update_settings/update_settings_config.dart';
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

// Рекурсивно преобразует YamlMap/YamlList в обычные Map/List
Object? deepConvert(Object? node) {
  if (node is YamlMap) {
    return Map<String, dynamic>.fromEntries(
      node.entries.map((e) => MapEntry(e.key.toString(), deepConvert(e.value))),
    );
  } else if (node is YamlList) {
    return node.map(deepConvert).toList();
  } else {
    return node;
  }
}

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
