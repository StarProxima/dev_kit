import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AutoVariableKey implements Key {
  AutoVariableKey();

  Key? key;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is AutoVariableKey && other.key == key;
  }

  @override
  int get hashCode => Object.hash(runtimeType, key);

  @override
  String toString() => 'AutoVariableKey($key)';
}
