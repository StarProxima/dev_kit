import '../../shared/update_platform.dart';

import 'source_config.dart';

class GlobalPlatformConfig {
  final UpdatePlatform platform;
  final GlobalSourceConfig? source;
  final Map<String, dynamic>? customData;

  const GlobalPlatformConfig({
    required this.platform,
    this.source,
    this.customData,
  });

  const GlobalPlatformConfig.byRequired({
    required this.platform,
    required this.source,
    required this.customData,
  });
}

class ReleasePlatformConfig {
  final UpdatePlatform platform;
  final ReleaseSourceConfig? source;
  final Map<String, dynamic>? customData;

  const ReleasePlatformConfig({
    required this.platform,
    required this.source,
    required this.customData,
  });

  const ReleasePlatformConfig.byRequired({
    required this.platform,
    this.source,
    this.customData,
  });
}
