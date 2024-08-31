import '../../entity/update_platform.dart';

class StoreDTO {
  final String name;
  final Uri? url;
  final List<UpdatePlatform>? platforms;
  final Map<String, dynamic> customData;

  const StoreDTO({
    required this.name,
    required this.url,
    required this.platforms,
    required this.customData,
  });
}
