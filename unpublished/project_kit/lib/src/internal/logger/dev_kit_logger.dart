import 'package:proxima_logger/proxima_logger.dart';

class DevKitLogger extends ProximaLoggerBase {
  /// Логгер, используемый в dev_kit.
  static final instance = DevKitLogger(
    settings: _settingsBuilder,
  );

  DevKitLogger({super.settings});

  static LogSettings _settingsBuilder(ILogType logType) {
    return switch (logType) {
      _ => const LogSettings(
          logParts: [
            LogPart.stack,
            LogPart.error,
            LogPart.divider,
            LogPart.message,
          ],
          skipStackTraceRegExp: 'package:riverpod|api_wrap',
        ),
    };
  }

  void debug(String? title, [Object? message]) {
    log(
      LogType.debug,
      title: title,
      message: message,
    );
  }

  void error({
    String? title,
    StackTrace? stack,
    Object? error,
    Object? message,
  }) {
    log(
      LogType.error,
      title: title,
      error: error,
      stack: stack,
      message: message,
    );
  }
}
