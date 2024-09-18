import '../../shared/update_platform.dart';
import '../../shared/update_status_wrapper.dart';
import 'release_config.dart';

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

class GlobalSourceConfig {
  final String name;
  final Uri url;
  final List<UpdatePlatform>? platforms;
  final UpdateSettingsConfig? settings;
  final Map<String, dynamic>? customData;

  const GlobalSourceConfig({
    required this.name,
    required this.url,
    required this.platforms,
    required this.settings,
    required this.customData,
  });
}

class ReleaseSourceConfig {
  final String name;
  final Uri? url;
  final List<UpdatePlatform>? platforms;
  final ReleaseConfig? release;
  final Map<String, dynamic>? customData;

  const ReleaseSourceConfig({
    required this.name,
    required this.url,
    required this.platforms,
    required this.release,
    required this.customData,
  });
}
