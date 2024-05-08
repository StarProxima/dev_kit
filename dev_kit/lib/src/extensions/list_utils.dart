import 'dart:math';

extension ListUtils<T> on Iterable<T> {
  static final _rand = Random();

  T get random => elementAt(_rand.nextInt(length));
}
