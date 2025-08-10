import '../shared/models/release/release_config.dart';
import '../shared/models/release/update_data.dart';

class UpdateReleaseTransformer {
  const UpdateReleaseTransformer();

  /// Преобразует релизы в конкретные обновления с источником и платформой.
  /// Из одного релиза может быть несколько обновлений.
  ///
  /// Мержит все правила в приоритете:
  /// [...releaseRules, ...releaseSourceRules, ...releasePlatformRules]
  /// в общий список правил в [UpdateData].
  List<UpdateData> updatesFromReleases(
    List<ReleaseConfig> releases,
  ) {
    throw UnimplementedError();
  }
}
