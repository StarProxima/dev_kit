import '../release_config/release_config.dart';
import '../release_platrform_config/release_platrform_config.dart';

class ReleaseSourceConfig {
  final String? name;
  final Uri? url;
  final List<ReleasePlatformConfig>? platforms;
  final ReleaseConfig? releaseOverride;
  final Map<String, dynamic>? customData;

  const ReleaseSourceConfig({
    this.name,
    this.url,
    this.platforms,
    this.releaseOverride,
    this.customData,
  });

  const ReleaseSourceConfig.byRequired({
    required this.name,
    required this.url,
    required this.platforms,
    required this.releaseOverride,
    required this.customData,
  });
}
