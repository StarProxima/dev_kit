import '../shared/models/global_source/global_source_config.dart';
import '../shared/models/release/release_config.dart';
import '../shared/models/release/update_data.dart';
import '../shared/models/update_rule/update_rules_container.dart';
import '../shared/update_entities/update_source.dart';
import 'sub_linkers/update_data_linker.dart';
import 'sub_linkers/update_release_linker.dart';

class UpdateLinker {
  const UpdateLinker();

  static const _updateReleaseLinker = UpdateReleaseLinker();
  static const _updateDataLinker = UpdateDataLinker();

  /// Преобразует релизы в конкретные обновления с источником и платформой
  /// и мержит все правила.
  List<UpdateData> linkAll({
    required List<ReleaseConfig> releases,
    required UpdateRulesContainer rulesContainer,
    required List<GlobalSourceConfig> globalSources,
  }) {
    final sources = globalSources.map((e) => e.toUpdateSource()).toList();

    final updates = _updateReleaseLinker.linkAll(
      releases: releases,
      sources: sources,
    );

    final finalUpdates = _updateDataLinker.linkAll(
      updates: updates,
      rulesContainer: rulesContainer,
      globalSources: globalSources,
    );

    return finalUpdates;
  }

  /// Преобразует релиз в конкретное обновление с источником и платформой
  /// и мержит все правила.
  List<UpdateData> link({
    required ReleaseConfig release,
    required UpdateRulesContainer rulesContainer,
    required List<GlobalSourceConfig> globalSources,
  }) {
    final sources = globalSources.map((e) => e.toUpdateSource()).toList();

    final updates = _updateReleaseLinker.link(
      release: release,
      sources: sources,
    );

    final finalUpdates = _updateDataLinker.linkAll(
      updates: updates,
      rulesContainer: rulesContainer,
      globalSources: globalSources,
    );

    return finalUpdates;
  }
}
