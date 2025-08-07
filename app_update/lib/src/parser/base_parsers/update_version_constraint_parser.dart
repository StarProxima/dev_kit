import '../../shared/update_version_constraint.dart';
import '../primitive_parsers/version_constraint_parser.dart';
import '../common.dart';

class UpdateVersionConstraintParser {
  static const _versionConstraintParser = VersionConstraintParser();

  const UpdateVersionConstraintParser();

  UpdateVersionConstraint? parse(
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is! String) throw const UpdateConfigException();

    final byName = UpdateVersionConstraint(null, name: value);

    if (UpdateVersionConstraint.values.contains(byName)) {
      return byName;
    }

    final versionConstraint = _versionConstraintParser.parse(value);

    if (versionConstraint == null) return null;

    return UpdateVersionConstraint(versionConstraint);
  }
}
