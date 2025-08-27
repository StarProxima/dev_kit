import 'package:pub_semver/pub_semver.dart';

import 'update_entity.dart';

// ignore: prefer-overriding-parent-equality
base class UpdateVersionConstraint extends UpdateEntityName {
  static const any = UpdateVersionConstraint(null, name: 'any');

  final VersionConstraint? versionConstraint;
  static const values = [];

  static const valuesWithAny = [
    ...values,
    any,
  ];

  const UpdateVersionConstraint(
    this.versionConstraint, {
    String name = 'direct',
  }) : super(name);

  @override
  List<Object?> get params => [name, versionConstraint];
}
