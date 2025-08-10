import 'package:collection/collection.dart';
import 'package:pub_semver/pub_semver.dart';

import '../shared/models/release/update_data.dart';
import '../shared/update_entities/update_platform.dart';
import '../shared/update_entities/update_source_name.dart';

class UpdateFinder {
  const UpdateFinder();

  /// Ищет последние обновления для конкретной платформы и источника,
  /// учитывая условия по версии и дате.
  List<UpdateData> find({
    required DateTime currentDate,
    required Version localVersion,
    required UpdatePlatform platform,
    required List<UpdateSourceName> sources,
    required List<UpdateData> updates,
  }) {
    // Сортировка в порядке убывания версии
    final sortedUpdates = updates.sorted((a, b) => b.version.compareTo(a.version));

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
