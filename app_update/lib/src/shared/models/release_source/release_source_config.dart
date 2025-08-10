import '../../update_entities/update_source.dart';
import '../release/release_config.dart';
import '../release_platrform/release_platrform_config.dart';

class ReleaseSourceConfig {
  final UpdateSource? source;
  final Uri? url;
  final List<ReleasePlatformConfig>? platforms;
  final ReleaseConfig? releaseOverride;
  final Map<String, dynamic>? customData;

  const ReleaseSourceConfig({
    this.source,
    this.url,
    this.platforms,
    this.releaseOverride,
    this.customData,
  });

  const ReleaseSourceConfig.byRequired({
    required this.source,
    required this.url,
    required this.platforms,
    required this.releaseOverride,
    required this.customData,
  });
}
