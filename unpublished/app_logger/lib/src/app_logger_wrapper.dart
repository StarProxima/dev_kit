import 'package:app_logger/app_logger.dart';
import 'package:app_logger/src/managers/log_manager.dart';
import 'package:proxima_logger/proxima_logger.dart' hide LogType;

final class AppLoggerWrapper extends ProximaLogger with LoggerToWidgetMixin {
  AppLoggerWrapper._();

  static final AppLoggerWrapper instance = AppLoggerWrapper._();

  @override
  void log(
    ILogType type, {
    String? title,
    dynamic error,
    StackTrace? stack,
    dynamic message,
  }) {
    super.log(type, title: title, error: error, stack: stack, message: message);
    addToLogWidget(type, title, message, stack.toString());
  }
}

mixin LoggerToWidgetMixin on ProximaLogger {
  void addToLogWidget(
    ILogType type,
    String? title,
    dynamic message,
    String? stacktrace,
  ) {
    final logModel = LogBean(
      message: message ?? '',
      title: title ?? '',
      time: DateTime.now(),
      stackTrace: stacktrace ?? '',
      type: type,
    );
    switch (logModel.type) {
      case LogType.request:
        break;
      case LogType.debug:
        LogManager.instance.addDebug(logModel);
        break;
      case LogType.info:
        LogManager.instance.addInfo(logModel);
        break;
      case LogType.error:
        LogManager.instance.addError(logModel);
        break;
      case LogType.route:
        LogManager.instance.addRoute(logModel);
        break;
      case LogType.warning:
        LogManager.instance.addWarning(logModel);
        break;
      case LogType.notification:
        LogManager.instance.addNotification(logModel);
        break;
      case LogType.analytics:
        LogManager.instance.addAnalytics(logModel);
        break;
    }
  }
}
