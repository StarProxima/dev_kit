import '../../../shared/update_platform.dart';

import '../global_source_config/global_source_config.dart';

class GlobalPlatformConfig {
  final UpdatePlatform name;
  final GlobalSourceConfig? sourceOverride;
  final Map<String, dynamic>? customData;

  const GlobalPlatformConfig({
    required this.name,
    this.sourceOverride,
    this.customData,
  });

  const GlobalPlatformConfig.byRequired({
    required this.name,
    required this.sourceOverride,
    required this.customData,
  });
}
