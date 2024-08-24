class StoreDTO {
  const StoreDTO({
    required this.name,
    required this.url,
    required this.platforms,
  });

  final String? name;
  final String? url;
  final List<String>? platforms;
}
