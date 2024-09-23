import 'package:flutter/foundation.dart';

import '../shared/update_platform.dart';

enum Sources {
  googlePlay,
  appStore,
  custom;

  factory Sources.parse(String name) => values.firstWhere(
        (e) => e.name == name,
        orElse: () => custom,
      );
}

@immutable
class Source {
  final Sources store;
  final Uri url;
  final List<UpdatePlatform> platforms;
  final Map<String, dynamic>? customData;

  final String? _name;
  String get name => _name ?? store.name;

  @override
  int get hashCode => url.hashCode;

  factory Source({
    required String name,
    required Uri url,
    required List<UpdatePlatform>? platforms,
    required Map<String, dynamic>? customData,
  }) {
    switch (Sources.parse(name)) {
      case Sources.googlePlay:
        return Source.googlePlay(url: url, customData: customData);

      case Sources.appStore:
        return Source.appStore(url: url, customData: customData);

      case Sources.custom:
        return Source.custom(
          name: name,
          url: url,
          platforms: platforms ?? (throw Exception('Custom source should contains platforms')),
          customData: customData,
        );
    }
  }

  const Source.googlePlay({
    required this.url,
    this.customData,
  })  : store = Sources.googlePlay,
        platforms = const [UpdatePlatform.android],
        _name = null;

  const Source.appStore({
    required this.url,
    this.customData,
  })  : store = Sources.appStore,
        platforms = const [UpdatePlatform.ios, UpdatePlatform.macos],
        _name = null;

  const Source.custom({
    required String name,
    required this.url,
    required this.platforms,
    this.customData,
  })  : store = Sources.custom,
        _name = name;

  @override
  bool operator ==(Object other) => other is Source && url == other.url;
}
