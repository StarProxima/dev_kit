import '../../../shared/update_platform.dart';
import '../release_source_config/release_source_config.dart';

class ReleasePlatformConfig {
  final UpdatePlatform name;
  final ReleaseSourceConfig? sourceOverride;
  final Map<String, dynamic>? customData;

  const ReleasePlatformConfig({
    required this.name,
    this.sourceOverride,
    this.customData,
  });

  const ReleasePlatformConfig.byRequired({
    required this.name,
    required this.sourceOverride,
    required this.customData,
  });
}
