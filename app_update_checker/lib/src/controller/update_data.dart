import '../config/entity/checker_config.dart';
import '../config/entity/release.dart';
import '../config/entity/version.dart';

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
