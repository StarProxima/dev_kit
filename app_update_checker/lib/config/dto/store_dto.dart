class StoreDTO {
  final String? name;
  final Uri? url;
  final List<String>? platforms;

  const StoreDTO({
    required this.name,
    required this.url,
    required this.platforms,
  });
}
