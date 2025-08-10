import '../shared/models/release/release_config.dart';
import '../shared/models/release/release_override_config.dart';
import '../shared/models/release/update_data.dart';
import '../shared/models/release_platrform/release_platrform_config.dart';
import '../shared/models/release_source/release_source_config.dart';
import '../shared/update_entities/update_source.dart';

class UpdateReleaseLinker {
  const UpdateReleaseLinker();

  /// Преобразует все релизы в конкретные обновления с источником и платформой.
  List<UpdateData> linkAll({
    required List<ReleaseConfig> releases,
    required List<UpdateSource> sources,
  }) {
    throw UnimplementedError();
  }

  /// Преобразует релиз в конкретные обновления с источником и платформой.
  ///
  /// Если [ReleaseSourceConfig.platforms] null (но не []), то платформы будет созданы
  /// из [UpdateSource.platforms] через [ReleasePlatformConfig] для каждого источника.
  ///
  /// Если источники  не заданы, то обновлений нет.
  /// Применяет [ReleaseOverrideConfig], чтобы переопределить параметры релиза.
  ///
  /// Мержит все правила в приоритете:
  /// [...releaseRules, ...releaseSourceRules, ...releasePlatformRules]
  /// в общий список правил в [UpdateData].
  List<UpdateData> link({
    required ReleaseConfig release,
    required List<UpdateSource> sources,
  }) {
    throw UnimplementedError();
  }
}
