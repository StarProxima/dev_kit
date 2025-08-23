import '../shared/models/global_source/global_source_config.dart';
import '../shared/models/release/release_config.dart';
import '../shared/models/release/update_data.dart';
import '../shared/models/update/update_config.dart';
import '../shared/update_entities/update_source.dart';
import 'sub_linkers/update_data_linker.dart';
import 'sub_linkers/update_release_linker.dart';

class UpdateLinker {
  const UpdateLinker();

  static const _updateReleaseLinker = UpdateReleaseLinker();
  static const _updateDataLinker = UpdateDataLinker();

  List<UpdateData> linkAll({
    required List<ReleaseConfig> releases,
    required UpdateConfig config,
    required List<GlobalSourceConfig> globalSources,
  }) {
    final sources = globalSources.map((e) => e.toUpdateSource()).toList();

    final updates = _updateReleaseLinker.linkAll(
      releases: releases,
      sources: sources,
    );

    final finalUpdates = _updateDataLinker.linkAll(
      updates: updates,
      config: config,
      globalSources: globalSources,
    );

    return finalUpdates;
  }

  List<UpdateData> link({
    required ReleaseConfig release,
    required UpdateConfig config,
    required List<GlobalSourceConfig> globalSources,
  }) {
    final sources = globalSources.map((e) => e.toUpdateSource()).toList();

    final updates = _updateReleaseLinker.link(
      release: release,
      sources: sources,
    );

    final finalUpdates = _updateDataLinker.linkAll(
      updates: updates,
      config: config,
      globalSources: globalSources,
    );

    return finalUpdates;
  }
}
