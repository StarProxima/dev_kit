import 'package:pub_semver/pub_semver.dart';

import 'update_entity.dart';

class UpdateVersionConstraint extends UpdateEntity {
  static const any = UpdateVersionConstraint(null, 'any');

  final VersionConstraint? versionConstraint;
  const UpdateVersionConstraint(this.versionConstraint, [super._name = 'direct']);

  @override
  List<Object?> get params => [name, versionConstraint];
}
