import 'package:flutter/material.dart';

import '../../shared/update_platform.dart';

@immutable
class StoreConfig {
  final String name;
  final Uri? url;
  final List<UpdatePlatform>? platforms;
  final Map<String, dynamic>? customData;

  const StoreConfig({
    required this.name,
    required this.url,
    required this.platforms,
    required this.customData,
  });
}
