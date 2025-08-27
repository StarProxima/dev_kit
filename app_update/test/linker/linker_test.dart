import 'package:app_update/app_update.dart';

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
