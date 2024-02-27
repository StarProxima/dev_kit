import 'package:auto_exporter_annotation/auto_exporter_annotation.dart';
import 'package:proxima_logger/proxima_logger.dart';

/// Логгер, используемый в dev_kit.
@IgnoreExport()
final logger = DevKitLogger(
  settings: _settingsBuilder,
);

LogSettings _settingsBuilder(ILogType logType) {
  return switch (logType) {
    _ => const LogSettings(
        logParts: [
          LogPart.stack,
          LogPart.error,
          LogPart.divider,
          LogPart.message,
        ],
        skipStackTraceRegExp: 'package:riverpod|api_wrap',
      )
  };
}

class DevKitLogger extends ProximaLoggerBase {
  DevKitLogger({super.settings});

  void debug(String? title, [dynamic message]) {
    log(
      LogType.debug,
      title: title,
      message: message,
    );
  }

  void error({
    String? title,
    StackTrace? stack,
    dynamic error,
    dynamic message,
  }) {
    log(
      LogType.error,
      title: title,
      message: message,
      error: error,
      stack: stack,
    );
  }
}
