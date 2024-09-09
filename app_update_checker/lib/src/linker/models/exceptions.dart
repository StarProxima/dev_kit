class CyclicDependenceException implements Exception {
  const CyclicDependenceException();

  @override
  String toString() {
    return 'CyclicDependenceException: There is cyclic dependence in releases by refVersions';
  }
}
