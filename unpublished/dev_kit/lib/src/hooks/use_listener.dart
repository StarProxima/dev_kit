import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void useListener(
  Listenable? listenable,
  VoidCallback listener, [
  List<Object?>? keys = const [],
]) {
  useEffect(
    () {
      listenable?.addListener(listener);
      return () => listenable?.removeListener(listener);
    },
    keys,
  );
}
