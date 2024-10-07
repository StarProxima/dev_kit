// ignore_for_file: prefer-boolean-prefixes

/// The status of the app version.
enum AppVersionStatus {
  /// The current version is not supported.
  /// The update must be required to be installed before using the application.
  unsupported,

  /// The current version is deprecated.
  /// It is recommended to install the update.
  deprecated,

  /// The current version is outdated.
  /// The update is available and can be installed.
  outdated;

  bool get isUnsupported => this == unsupported;

  bool get isDeprecated => this == deprecated;

  bool get isOutdated => this == outdated;


  // In terms of updates

  bool get updateIsRequired => isUnsupported;

  bool get updateIsRecommended => isDeprecated;

  bool get updateIsAvailable => isOutdated;
}
