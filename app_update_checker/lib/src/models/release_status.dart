enum ReleaseStatus {
  /// The release is required be installed by all users with older versions.
  /// Every old release will be [broken].
  required,

  /// The release is outdated and is strictly recommended to be updated.
  /// Every old release will be [deprecated].
  recommended,

  /// The release is available for install.
  /// It can be optionally updated by users.
  active,

  /// The release is not available yet and is hidden to users.
  /// Need it when the release is still being reviewed or has not been shipped yet.
  inactive,

  /// The release is outdated and is strictly recommended to be updated.
  /// For this release, any new release will be [recommended].
  deprecated,

  /// The release has critical bugs and requires an update.
  /// For this release, any new release will be [required].
  broken;

  static ReleaseStatus? parse(String? str) => List<ReleaseStatus?>.of(values).firstWhere(
        (e) => e?.name == str,
        orElse: () => null,
      );

  bool get isRequired => this == required;

  bool get isRecommended => this == recommended;

  bool get isActive => this == active;

  bool get isInactive => this == inactive;

  bool get isDeprecated => this == deprecated;

  bool get isBroken => this == broken;
}
