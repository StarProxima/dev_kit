import 'package:collection/collection.dart';
import 'package:pub_semver/pub_semver.dart';

import '../shared/models/release/update_data.dart';
import '../shared/update_entities/update_platform.dart';
import '../shared/update_entities/update_source_name.dart';

class UpdateFinder {
  const UpdateFinder();

  /// Ищет последние подходящие обновления для конкретной платформы и источника,
  /// учитывая фильтры по версии и дате.
  ///
  /// При одинаковой версии сортирует по приоритету источника согласно порядку в [sources].
  List<UpdateData> find({
    required DateTime currentDate,
    required Version localVersion,
    required UpdatePlatform platform,
    required List<UpdateSourceName> sources,
    required List<UpdateData> updates,
  }) {
    // Сортировка: по версии по убыванию, при равной версии — по приоритету источника из [sources]
    final sortedUpdates = updates.sorted((a, b) {
      final byVersionDesc = b.version.compareTo(a.version);
      if (byVersionDesc != 0) return byVersionDesc;

      final aIdx = sources.indexOf(a.sourceName);
      final bIdx = sources.indexOf(b.sourceName);
      final aSafe = aIdx < 0 ? sources.length : aIdx;
      final bSafe = bIdx < 0 ? sources.length : bIdx;
      return aSafe.compareTo(bSafe);
    });

    final result = <UpdateData>[];

    for (final update in sortedUpdates) {
      if (result.any((e) => e.sourceName == update.sourceName && e.platform == update.platform)) {
        continue;
      }

      if (update.version < localVersion) break;
      if (update.date?.isAfter(currentDate) ?? false) continue;
      if (update.platform != platform) continue;
      if (!sources.contains(update.sourceName)) continue;

      result.add(update);
    }

    return result;
  }
}
