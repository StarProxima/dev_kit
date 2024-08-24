enum Stores {
  googlePlay,
  appStore,
  customStore;

  factory Stores.fromString(String name) => values.firstWhere(
        (e) => e.name == name,
        orElse: () => customStore,
      );
}
