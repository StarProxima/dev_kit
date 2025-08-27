import '../../entities/update_version_constraint.dart';
import '../parse_config_exeption.dart';
import '../primitive_parsers/version_constraint_parser.dart';

class UpdateVersionConstraintParser {
  static const _versionConstraintParser = VersionConstraintParser();

  const UpdateVersionConstraintParser();

  UpdateVersionConstraint? parse(
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is! String) {
      throw ParseConfigException.wrongType(
        rightType: String,
        wrongType: value.runtimeType,
        parserType: UpdateVersionConstraintParser,
        configs: [value],
      );
    }

    final byName = UpdateVersionConstraint(null, name: value);

    if (UpdateVersionConstraint.values.contains(byName)) {
      return byName;
    }

    final versionConstraint = _versionConstraintParser.parse(value);

    if (versionConstraint == null) return null;

    return UpdateVersionConstraint(versionConstraint);
  }
}
