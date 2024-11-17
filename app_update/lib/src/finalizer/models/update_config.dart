import '../../sources/release_source.dart';
import 'release.dart';

class UpdateConfig {
  final List<ReleaseSource> sources;
  final List<Release> releases;
  final Map<String, dynamic>? customData;

  const UpdateConfig({
    required this.sources,
    required this.releases,
    required this.customData,
  });
}
