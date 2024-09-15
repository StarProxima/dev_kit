import '../../shared/update_status_wrapper.dart';
import '../models/update_config_exception.dart';
import '../update_config_parser.dart';

class BoolParser {
  UpdateStatusWrapperParser get updateStatusWrapperParser => const UpdateStatusWrapperParser();

  const BoolParser();

  UpdateStatusWrapper<bool?> parseWithStatuses(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isDebug,
    required WrapperMode mode,
  }) {
    // ignore: avoid-inferrable-type-arguments
    return updateStatusWrapperParser.parse<bool?>(
      value,
      parse: (value) => parse(value, isDebug: isDebug),
      mode: mode,
    );
  }

  // ignore: prefer-boolean-prefixes
  bool? parse(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isDebug,
  }) {
    if (value is bool?) return value;
    if (isDebug) throw const UpdateConfigException();

    return null;
  }
}
