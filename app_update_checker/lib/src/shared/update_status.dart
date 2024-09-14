enum UpdateStatus {
  /// The current version is not supported.
  /// The update must be required to be installed before using the application.
  required,

  /// The current version is deprecated.
  /// It is recommended to install the update.
  recommended,

  /// The current version is outdated.
  /// The update can be installed.
  available;

  bool get isRequired => this == required;

  bool get isRecommended => this == recommended;

  bool get isAvailable => this == available;
}
