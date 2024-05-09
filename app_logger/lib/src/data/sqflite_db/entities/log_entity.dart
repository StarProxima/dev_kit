import 'package:app_logger/src/utils/enum_ext.dart';
import 'package:app_logger/src/utils/map_ext.dart';
import 'package:proxima_logger/proxima_logger.dart';

final class LogEntity {
  LogEntity({
    required this.id,
    required this.message,
    required this.time,
    required this.stackTrace,
    required this.type,
    required this.title,
    this.data = '',
    this.key,
  });

  factory LogEntity.fromJson(Map<String, dynamic> json) {
    return LogEntity(
      key: json['key'],
      message: json['message'],
      time: DateTime.tryParse(json['time'])?.toLocal(),
      stackTrace: json['stacktrace'],
      type: LogType.values.valueOf(json['type']) ?? LogType.info,
      data: json['data'],
      id: json['id'],
      title: json['title'],
    );
  }

  final int? key;
  final String id;
  final String message;
  final String? title;
  final DateTime? time;
  final String? stackTrace;
  final String? data;
  final ILogType type;

  /// [key] should not be in this method, because the database increments it itself.
  Map<String, dynamic> toJson() {
    final json = {
      'id': id,
      'message': message.toString(),
      'time': time?.toUtc().toString(),
      'stacktrace': stackTrace?.toString(),
      'data': data?.toString(),
      'type': type.label.toString(),
      'title': title.toString(),
    };

    // ignore: cascade_invocations
    json.clearAllNull();

    return json;
  }
}
