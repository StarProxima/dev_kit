import '../config/entity/checker_config.dart';
import '../config/entity/release.dart';
import '../config/entity/version.dart';

class UpdateNotFoundException implements Exception {
  const UpdateNotFoundException();
}

class UpdateSkippedException implements Exception {
  final UpdateData updateData;

  const UpdateSkippedException({
    required this.updateData,
  });
}

class UpdatePostponedException implements Exception {
  final UpdateData updateData;

  const UpdatePostponedException({
    required this.updateData,
  });
}

class UpdateData {
  final String appName;
  final Version appVersion;
  // ignore: prefer-boolean-prefixes
  final bool appVersonIsDeprecated;
  final CheckerConfig config;
  final Release release;

  const UpdateData({
    required this.appName,
    required this.appVersion,
    required this.appVersonIsDeprecated,
    required this.config,
    required this.release,
  });
}
