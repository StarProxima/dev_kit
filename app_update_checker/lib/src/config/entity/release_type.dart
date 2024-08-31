enum ReleaseType {
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
}
