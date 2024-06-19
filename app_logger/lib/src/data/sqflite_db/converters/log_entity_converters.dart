import 'package:app_logger/app_logger.dart';
import 'package:app_logger/src/data/sqflite_db/entities/log_entity.dart';
import 'package:app_logger/src/utils/parsers/isolate_parser.dart';

final class LogEntityConverter {
  final _parser = IsolateParser();

  Future<LogBean> inToOut(LogEntity inObject) async {
    final data = inObject.data;

    return LogBean(
      id: inObject.id,
      message: await _parser.decode(inObject.message),
      time: inObject.time?.toLocal() ?? DateTime.now(),
      stackTrace: inObject.stackTrace,
      data: data != null ? await _parser.decode(data) : null,
      key: inObject.key,
      type: inObject.type,
      title: inObject.title,
    );
  }

  Future<LogEntity> outToIn(LogBean outObject) async {
    final data = outObject.data;

    return LogEntity(
      message: await _parser.encode(outObject.message),
      time: outObject.time.toUtc(),
      stackTrace: outObject.stackTrace,
      data: data != null && data.isNotEmpty ? await _parser.encode(data) : null,
      type: outObject.type ?? LogType.info,
      id: outObject.id,
      key: outObject.key ?? 0,
      title: outObject.title ?? '',
    );
  }
}
