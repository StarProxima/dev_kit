import '../parser/sub_parsers/update_rule_config/update_rule_config.dart';
import 'models/mergeable.dart';
import 'models/update_search_data.dart';

class UpdateRuleResolver {
  const UpdateRuleResolver();

  UpdateRuleConfig resolve<T extends Mergeable>({
    required UpdateSearchData searchData,
    required List<UpdateRuleConfig<T>> rules,
  }) {
    throw UnimplementedError();
  }
}
