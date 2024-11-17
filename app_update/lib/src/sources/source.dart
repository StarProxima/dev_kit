import 'package:flutter/foundation.dart';

import '../parser/models/platform_config.dart';
import '../parser/models/source_config.dart';
import '../shared/update_platform.dart';
import '../shared/update_settings_container.dart';
import '../shared/update_text_container.dart';
import 'sources.dart';

@immutable
class Source {
  final Sources type;
  final Uri url;
  final List<UpdatePlatform> platforms;
  // TODO скрыть Config из названия
  final UpdateTextConfigContainer? text;
  final UpdateSettingsConfigContainer? settings;
  final Map<String, dynamic>? customData;

  final String? _name;
  String get name => _name ?? type.name;

  String get title => type.title ?? name;

  Source({
    required String name,
    required this.url,
    required this.platforms,
    required this.text,
    required this.settings,
    required this.customData,
  })  : _name = name,
        type = Sources.parse(name);

  GlobalSourceConfig toGlobalSourceConfig() => GlobalSourceConfig(
        name: _name,
        url: url,
        platforms: platforms.map((p) => GlobalPlatformConfig(platform: p)).toList(),
        text: text,
        settings: settings,
        customData: customData,
      );
}
