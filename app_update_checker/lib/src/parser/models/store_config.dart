import '../../shared/update_platform.dart';
import '../../shared/update_status_wrapper.dart';
import 'release_config.dart';
import 'release_settings_config.dart';

abstract class SourceConfig {
  final String name;
  final Uri? url;
  final List<UpdatePlatform>? platforms;
  final Map<String, dynamic>? customData;

  const SourceConfig({
    required this.name,
    required this.url,
    required this.platforms,
    required this.customData,
  });
}

class GlobalSourceConfig extends SourceConfig {
  final UpdateStatusWrapper<ReleaseSettingsConfig?>? releaseSettings;

  const GlobalSourceConfig({
    required super.name,
    required super.url,
    required super.platforms,
    required this.releaseSettings,
    required super.customData,
  });
}

class ReleaseSourceConfig extends SourceConfig {
  final ReleaseConfig? release;

  const ReleaseSourceConfig({
    required super.name,
    required super.url,
    required super.platforms,
    required this.release,
    required super.customData,
  });
}
