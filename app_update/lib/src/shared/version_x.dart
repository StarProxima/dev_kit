import 'package:pub_semver/pub_semver.dart';

extension VersionX on Version {
  String toOnlyNumbersString() => '$major.$minor.$patch';

  String toVersionWithBuildString() => '$major.$minor.$patch${build.isNotEmpty ? '+${build.join('.')}' : ''}';
}
