enum ReleaseStatus {
  // The release is available.
  active,

  // The release is hidden from users.
  inactive,

  // The release is required be installed by all users with older versions.
  required,

  // The release is outdated and is strictly recommended to be updated.
  deprecated,

  // The release has critical bugs and requires an update.
  broken;

  static ReleaseStatus? parse(String? str) =>
      List<ReleaseStatus?>.of(values).firstWhere(
        (e) => e?.name == str,
        orElse: () => null,
      );

  bool get isActive => this == active;

  bool get isInactive => this == inactive;

  bool get isRequired => this == required;

  bool get isDeprecated => this == deprecated;

  bool get isBroken => this == broken;
}
