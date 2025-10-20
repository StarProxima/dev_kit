// ignore_for_file: avoid-type-casts

import 'package:pub_semver/pub_semver.dart';

class StorageData {
  final DateTime? allUpdatesPostponedUntil;
  final List<PostponedUpdate> postponedUpdates;
  final List<PostponedUpdate> skippedUpdates;

  const StorageData({
    required this.allUpdatesPostponedUntil,
    required this.postponedUpdates,
    required this.skippedUpdates,
  });

  factory StorageData.empty() => const StorageData(
        allUpdatesPostponedUntil: null,
        postponedUpdates: [],
        skippedUpdates: [],
      );

  Map<String, dynamic> toJson() => {
        'all_updates_postponed_until':
            allUpdatesPostponedUntil?.toIso8601String(),
        'postponed_updates':
            postponedUpdates.map((update) => update.toJson()).toList(),
        'skipped_updates':
            skippedUpdates.map((update) => update.toJson()).toList(),
      };

  factory StorageData.fromJson(Map<String, dynamic> json) {
    final allUpdatesPostponedUntilStr =
        json['all_updates_postponed_until'] as String?;
    final postponedUpdatesList = json['postponed_updates'] as List?;
    final skippedUpdatesList = json['skipped_updates'] as List?;

    return StorageData(
      allUpdatesPostponedUntil: allUpdatesPostponedUntilStr == null
          ? null
          : DateTime.parse(allUpdatesPostponedUntilStr),
      postponedUpdates: postponedUpdatesList
              ?.map((item) =>
                  PostponedUpdate.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      skippedUpdates: skippedUpdatesList
              ?.map((item) =>
                  PostponedUpdate.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class PostponedUpdate {
  final Version version;
  final DateTime postponedUntil;

  const PostponedUpdate({
    required this.version,
    required this.postponedUntil,
  });

  Map<String, dynamic> toJson() => {
        'version': version.toString(),
        'postponed_until': postponedUntil.toIso8601String(),
      };

  factory PostponedUpdate.fromJson(Map<String, dynamic> json) {
    return PostponedUpdate(
      version: Version.parse(json['version'] as String),
      postponedUntil: DateTime.parse(json['postponed_until'] as String),
    );
  }
}
