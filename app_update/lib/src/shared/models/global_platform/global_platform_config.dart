import '../../update_entities/update_platform.dart';

import '../global_source/global_source_config.dart';

class GlobalPlatformConfig {
  final UpdatePlatform platform;
  final GlobalSourceConfig? sourceOverride;
  final Map<String, dynamic>? customData;

  const GlobalPlatformConfig({
    required this.platform,
    this.sourceOverride,
    this.customData,
  });

  const GlobalPlatformConfig.byRequired({
    required this.platform,
    required this.sourceOverride,
    required this.customData,
  });
}
