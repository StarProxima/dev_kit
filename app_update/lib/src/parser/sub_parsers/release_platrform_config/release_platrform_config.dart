import '../../../shared/update_platform.dart';
import '../release_source_config/release_source_config.dart';

class ReleasePlatformConfig {
  final UpdatePlatform platform;
  final ReleaseSourceConfig? sourceOverride;
  final Map<String, dynamic>? customData;

  const ReleasePlatformConfig({
    required this.platform,
    this.sourceOverride,
    this.customData,
  });

  const ReleasePlatformConfig.byRequired({
    required this.platform,
    required this.sourceOverride,
    required this.customData,
  });
}
