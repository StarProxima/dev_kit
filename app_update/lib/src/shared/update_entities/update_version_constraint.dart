import 'package:pub_semver/pub_semver.dart';

import 'update_entity.dart';

class UpdateVersionConstraint extends UpdateEntityName {
  static const any = UpdateVersionConstraint(null, name: 'any');

  final VersionConstraint? versionConstraint;
  const UpdateVersionConstraint(this.versionConstraint, {String name = 'direct'}) : super(name);

  @override
  List<Object?> get params => [name, versionConstraint];

  static const values = [
    any,
  ];
}
