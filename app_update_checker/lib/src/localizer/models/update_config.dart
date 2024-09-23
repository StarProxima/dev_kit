import '../../sources/source.dart';
import 'release.dart';

class UpdateConfig {
  final List<Source> sources;
  final List<Release> releases;
  final Map<String, dynamic>? customData;

  const UpdateConfig({
    required this.sources,
    required this.releases,
    required this.customData,
  });
}
