class UpdateContainerStorage<T> {
  final T? global;
  final T? globalSource;
  final T? globalSourcePlatform;
  final T? release;
  final T? releaseSource;
  final T? releaseSourcePlatform;

  const UpdateContainerStorage({
    required this.global,
    required this.globalSource,
    required this.globalSourcePlatform,
    required this.release,
    required this.releaseSource,
    required this.releaseSourcePlatform,
  });
}
