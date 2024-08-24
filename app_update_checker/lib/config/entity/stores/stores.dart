enum Stores {
  googlePlay,
  appStore,
  custom;

  factory Stores.fromString(String name) => values.firstWhere(
        (e) => e.name == name,
        orElse: () => custom,
      );
}
