import 'package:version/version.dart';

extension VersionX on Version {
  String toOnlyNumbersString() => '$major.$minor.$patch';

  String toVersionWithBuildString() => '$major.$minor.$patch${build.trim().isNotEmpty ? '+${build.trim()}' : ''}';
}
