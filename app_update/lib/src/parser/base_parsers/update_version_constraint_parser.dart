import '../../shared/update_version_constraint.dart';
import '../primitive_parsers/version_constraint_parser.dart';
import '../update_config_exception.dart';

class UpdateVersionConstraintParser {
  static const _versionConstraintParser = VersionConstraintParser();

  const UpdateVersionConstraintParser();

  UpdateVersionConstraint? parse(
    dynamic value,
  ) {
    if (value! is String?) throw const UpdateConfigException();

    final versionConstraint = _versionConstraintParser.parse(value);

    if (versionConstraint == null) return null;

    final byName = UpdateVersionConstraint(null, name: value);

    if (UpdateVersionConstraint.values.contains(byName)) {
      return byName;
    }

    return UpdateVersionConstraint(versionConstraint);
  }
}
