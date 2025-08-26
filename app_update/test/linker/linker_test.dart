library linker_test;

import 'package:app_update/src/linker/sub_linkers/update_data_linker.dart';
import 'package:app_update/src/linker/sub_linkers/update_release_linker.dart';
import 'package:app_update/src/linker/update_inker.dart';
import 'package:app_update/src/shared/entities/app_status.dart';
import 'package:app_update/src/shared/entities/update_platform.dart';
import 'package:app_update/src/shared/entities/update_source.dart';
import 'package:app_update/src/shared/entities/update_source_name.dart';
import 'package:app_update/src/shared/entities/update_version_constraint.dart';
import 'package:app_update/src/shared/models/global_platform/global_platform_config.dart';
import 'package:app_update/src/shared/models/global_source/global_source_config.dart';
import 'package:app_update/src/shared/models/release/release_config.dart';
import 'package:app_update/src/shared/models/release/release_override_config.dart';
import 'package:app_update/src/shared/models/release/update_data.dart';
import 'package:app_update/src/shared/models/release_platrform/release_platrform_config.dart';
import 'package:app_update/src/shared/models/release_source/release_source_config.dart';
import 'package:app_update/src/shared/models/update/update_config.dart';
import 'package:app_update/src/shared/models/update_app_settings/update_app_settings_config.dart';
import 'package:app_update/src/shared/models/update_content/update_content_config.dart';
import 'package:app_update/src/shared/models/update_rule/update_rule_config.dart';
import 'package:app_update/src/shared/models/update_rule/update_rules_container.dart';
import 'package:app_update/src/shared/models/update_settings/update_settings_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

part 'groups/update_data_linker_test_group.dart';
part 'groups/update_linker_integration_test_group.dart';
part 'groups/update_release_linker_test_group.dart';
part 'helpers/linker_helper.dart';

void main() {
  group('Linker', () {
    runUpdateDataLinkerTests();
    runUpdateReleaseLinkerTests();
    runUpdateLinkerIntegrationTests();
  });
}
