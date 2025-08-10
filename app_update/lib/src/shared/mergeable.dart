mixin Mergeable {
  Mergeable merge(Mergeable other);

  Map<String, dynamic>? mergeCustomData(
    Map<String, dynamic>? customData1,
    Map<String, dynamic>? customData2,
  ) {
    final customData = {
      ...?customData1,
      ...?customData2,
    };

    return customData.isNotEmpty ? customData : null;
  }
}
