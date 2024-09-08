import '../config/entity/checker_config.dart';
import '../config/entity/release.dart';
import '../config/entity/version.dart';

class UpdateNotFoundException implements Exception {
  const UpdateNotFoundException();
}

class UpdateSkippedException implements Exception {
  final AppUpdate update;

  const UpdateSkippedException({
    required this.update,
  });
}

class UpdatePostponedException implements Exception {
  final AppUpdate update;

  const UpdatePostponedException({
    required this.update,
  });
}

class AppUpdate {
  final String appName;
  final Version appVersion;
  final CheckerConfig config;
  final Release availableRelease;

  const AppUpdate({
    required this.appName,
    required this.appVersion,
    required this.config,
    required this.availableRelease,
  });
}
