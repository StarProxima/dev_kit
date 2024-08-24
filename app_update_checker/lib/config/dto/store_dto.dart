class StoreDTO {
  final String? name;
  final Uri? url;
  final List<String>? platforms;
  final Map<String, dynamic>? customData;

  const StoreDTO({
    required this.name,
    required this.url,
    required this.platforms,
    required this.customData,
  });
}
