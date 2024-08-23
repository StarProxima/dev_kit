import 'package:app_logger/src/res/colors.dart';
import 'package:flutter/material.dart';
import 'package:proxima_logger/proxima_logger.dart';
import 'package:uuid/uuid.dart';

final class LogBean implements Comparable<LogBean> {
  LogBean({
    required this.message,
    required this.time,
    required this.stackTrace,
    this.title,
    this.showToast = false,
    this.type,
    this.data = const {},
    this.key,
    String? id,
  })  : id = id ?? const Uuid().v4(),
        color = CRLoggerColors.primaryColor;

  final int? key;
  final String id;
  final dynamic message;
  final String? title;
  final DateTime time;
  final String? stackTrace;
  final Map<String, dynamic>? data;
  ILogType? type;
  Color color;
  bool showToast;

  @override
  int compareTo(LogBean other) {
    return other.time.isAfter(time) ? 1 : -1;
  }
}
