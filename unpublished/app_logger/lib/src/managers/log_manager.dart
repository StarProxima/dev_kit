import 'dart:async';

import 'package:app_logger/app_logger.dart';
import 'package:app_logger/src/app_logger_helper.dart';
import 'package:app_logger/src/controllers/logs_mode_controller.dart';
import 'package:app_logger/src/providers/sqflite_provider.dart';
import 'package:flutter/cupertino.dart';

final class LogManager {
  LogManager._() {
    _httpMng
      ..addRequest = addRequest
      ..addResponse = addResponse
      ..addError = addHttpError;
  }

  static final instance = LogManager._();

  int maxLogsCount = AppLoggerHelper.instance.maxLogsCount;

  final localLogs = StreamController<LogBean>.broadcast();

  List<LogBean> allLogs = [];
  List<LogBean> logDebug = [];
  List<LogBean> logInfo = [];
  List<LogBean> logNotification = [];
  List<LogBean> logAnalytics = [];
  List<LogBean> logRoute = [];
  List<LogBean> logError = [];
  List<LogBean> logWarning = [];

  List<LogBean> logDebugDB = [];
  List<LogBean> logInfoDB = [];
  List<LogBean> logNotificationDB = [];
  List<LogBean> logAnalyticsDB = [];
  List<LogBean> logRouteDB = [];
  List<LogBean> logErrorDB = [];
  List<LogBean> logWarningDB = [];

  final _provider = SqfliteProvider.instance;
  final _useDB = AppLoggerHelper.instance.useDB;
  final _httpMng = HttpLogManager.instance;

  ValueNotifier<LogBean?> logToastNotifier = ValueNotifier<LogBean?>(null);

  Function? onDebugUpdate;
  Function? onInfoUpdate;
  Function? onErrorUpdate;
  Function? onAnalyticsUpdate;
  Function? onRouteUpdate;
  Function? onWarningUpdate;
  Function? onNotificationUpdate;
  Function? onSearchPageUpdate;
  Function? onAllUpdate;
  Function? onLogsClear;
  ValueChanged<LogBean>? onLogAdded;

  Future<void> loadLogsFromDB({bool getWithCurrentLogs = false}) =>
      _filterLogByType(getWithCurrentLogs: getWithCurrentLogs);

  Future<void> cleanDebug() async {
    await _clearLogs(LogType.debug);
    onDebugUpdate?.call();
  }

  Future<void> cleanInfo() async {
    await _clearLogs(LogType.info);
    onInfoUpdate?.call();
  }

  Future<void> cleanError() async {
    await _clearLogs(LogType.error);
    onErrorUpdate?.call();
  }

  Future<void> cleanAnalytics() async {
    await _clearLogs(LogType.analytics);
    onAnalyticsUpdate?.call();
  }

  Future<void> cleanNotification() async {
    await _clearLogs(LogType.notification);
    onNotificationUpdate?.call();
  }

  Future<void> cleanRoute() async {
    await _clearLogs(LogType.route);
    onRouteUpdate?.call();
  }

  Future<void> cleanWarning() async {
    await _clearLogs(LogType.warning);
    onWarningUpdate?.call();
  }

  Future<void> clean({bool cleanDB = false}) async {
    if (cleanDB && _useDB) {
      await deleteAllLogs();
    }
    await _httpMng.cleanAllLogs(cleanDB: cleanDB);

    logDebug.clear();
    logInfo.clear();
    logError.clear();
    logWarning.clear();
    logAnalytics.clear();
    logRoute.clear();
    logNotification.clear();
    onAllUpdate?.call();
  }

  Future<void> addDebug(LogBean log) async {
    await _add(log, logDebug);
    onDebugUpdate?.call();
    onAllUpdate?.call();
    onSearchPageUpdate?.call();
  }

  Future<void> addInfo(LogBean log) async {
    await _add(log, logInfo);
    onInfoUpdate?.call();
    onAllUpdate?.call();
    onSearchPageUpdate?.call();
  }

  Future<void> addError(LogBean log) async {
    await _add(log, logError);
    onErrorUpdate?.call();
    onAllUpdate?.call();
    onSearchPageUpdate?.call();
  }

  Future<void> addWarning(LogBean log) async {
    await _add(log, logWarning);
    onWarningUpdate?.call();
    onAllUpdate?.call();
    onSearchPageUpdate?.call();
  }

  Future<void> addAnalytics(LogBean log) async {
    await _add(log, logAnalytics);
    onAnalyticsUpdate?.call();
    onAllUpdate?.call();
    onSearchPageUpdate?.call();
  }

  Future<void> addRoute(LogBean log) async {
    await _add(log, logRoute);
    onRouteUpdate?.call();
    onAllUpdate?.call();
    onSearchPageUpdate?.call();
  }

  Future<void> addNotification(LogBean log) async {
    await _add(log, logNotification);
    onNotificationUpdate?.call();
    onAllUpdate?.call();
    onSearchPageUpdate?.call();
  }

  void addRequest(HttpBean bean) {
    allLogs.add(
      LogBean(
        title: 'REQUEST ${bean.request?.url}',
        message:
            '${bean.request?.body ?? ''} \\n ${bean.request?.params ?? ''}',
        time: bean.request?.requestTime ?? DateTime.now(),
        stackTrace: null,
      ),
    );
  }

  void addResponse(HttpBean bean) {
    allLogs.add(
      LogBean(
        title: 'RESPONSE ${bean.response?.url}',
        message: '${bean.response?.headers ?? ''} \\n ${bean.response?.data}',
        time: bean.response?.responseTime ?? DateTime.now(),
        stackTrace: null,
      ),
    );
  }

  void addHttpError(HttpBean bean) {
    allLogs.add(
      LogBean(
        title: 'ERROR ${bean.error?.url}',
        message: bean.error?.errorMessage ?? '',
        time: bean.error?.time ?? DateTime.now(),
        stackTrace: bean.error?.errorData.toString(),
      ),
    );
  }

  Future<void> saveLog(LogBean log) => _provider.saveLog(log);

  Future<void> deleteAllLogs() async {
    await _provider.deleteAllLogs();
    _clearAllDBLogs();
  }

  Future<void> removeLog(LogBean log) async {
    logDebug.removeWhere((element) => element.id == log.id);
    logInfo.removeWhere((element) => element.id == log.id);
    logError.removeWhere((element) => element.id == log.id);
    logAnalytics.removeWhere((element) => element.id == log.id);
    logRoute.removeWhere((element) => element.id == log.id);
    logWarning.removeWhere((element) => element.id == log.id);
    logNotification.removeWhere((element) => element.id == log.id);

    if (_useDB) {
      logDebugDB.removeWhere((element) => element.id == log.id);
      logInfoDB.removeWhere((element) => element.id == log.id);
      logErrorDB.removeWhere((element) => element.id == log.id);
      logAnalyticsDB.removeWhere((element) => element.id == log.id);
      logRouteDB.removeWhere((element) => element.id == log.id);
      logWarningDB.removeWhere((element) => element.id == log.id);
      logNotificationDB.removeWhere((element) => element.id == log.id);
      await _deleteLogFromDB(log);
    }

    onAllUpdate?.call();
    onSearchPageUpdate?.call();
  }

  Future<void> addLogToDB(LogBean log) async {
    if (_useDB) {
      await saveLog(log);
    }
  }

  void addLogToListByType(LogType type, LogBean log) {
    switch (type) {
      case LogType.debug:
        logDebug.insert(0, log);
        logDebug = sortLogsByTime(logDebug);
        break;
      case LogType.info:
        logInfo.insert(0, log);
        logInfo = sortLogsByTime(logInfo);
        break;
      case LogType.error:
        logError.insert(0, log);
        logError = sortLogsByTime(logError);
        break;
      case LogType.warning:
        logWarning.insert(0, log);
        logWarning = sortLogsByTime(logWarning);
        break;
      case LogType.route:
        logRoute.insert(0, log);
        logRoute = sortLogsByTime(logRoute);
        break;
      case LogType.notification:
        logNotification.insert(0, log);
        logNotification = sortLogsByTime(logNotification);
        break;
      case LogType.analytics:
        logAnalytics.insert(0, log);
        logAnalytics = sortLogsByTime(logAnalytics);
        break;
      default:
    }

    onAllUpdate?.call();
    onSearchPageUpdate?.call();
  }

  void addLogToDBListByType(LogType type, LogBean log) {
    switch (type) {
      case LogType.debug:
        logDebugDB.insert(0, log);
        logDebugDB = sortLogsByTime(logDebugDB);
        break;
      case LogType.info:
        logInfoDB.insert(0, log);
        logInfoDB = sortLogsByTime(logInfoDB);
        break;
      case LogType.error:
        logErrorDB.insert(0, log);
        logErrorDB = sortLogsByTime(logErrorDB);
        break;
      case LogType.warning:
        logWarningDB.insert(0, log);
        logWarningDB = sortLogsByTime(logWarningDB);
        break;
      case LogType.route:
        logRouteDB.insert(0, log);
        logRouteDB = sortLogsByTime(logRouteDB);
        break;
      case LogType.notification:
        logNotificationDB.insert(0, log);
        logNotificationDB = sortLogsByTime(logNotificationDB);
        break;
      case LogType.analytics:
        logAnalyticsDB.insert(0, log);
        logAnalyticsDB = sortLogsByTime(logAnalyticsDB);
        break;
      default:
    }

    onAllUpdate?.call();
    onSearchPageUpdate?.call();
  }

  List<LogBean> sortLogsByTime(List<LogBean> logs) {
    logs.sort((a, b) => a.time.compareTo(b.time));

    return logs;
  }

  /// If the number of logs exceeds the limit, a shift happens.
  /// The first item is deleted and a new one is added to the end of the list.
  ///
  /// When displayed, the list is inverted, thus displaying the new logs at
  /// the beginning
  Future<void> _add(
    LogBean log,
    List<LogBean> logs,
  ) async {
    if (logs.length >= maxLogsCount) {
      logs.removeAt(0);
    }

    logs.add(log);
    localLogs.add(log);
    final isProvider = log.title?.toLowerCase().contains('provider') ?? false;
    if (!isProvider) {
      allLogs.add(log);
    }
    if (isProvider && (AppLoggerHelper.instance.isShareProviders ?? false)) {
      allLogs.add(log);
    }

    /// Display snack bar
    if (log.showToast) {
      onLogAdded?.call(log);
    }

    if (_useDB) {
      await saveLog(log);
    }
  }

  Future<void> _deleteLogFromDB(LogBean log) async {
    final logs = await _provider.getAllSavedLogs();
    final savedLogs = logs.where((element) => element.id == log.id).toList();
    await _provider.deleteLogs(savedLogs);
  }

  Future<void> _filterLogByType({bool getWithCurrentLogs = false}) async {
    if (_useDB) {
      _clearAllDBLogs();
      final logs = await _provider.getAllSavedLogs();
      final keysD = <String>[...logDebug.map((e) => e.id)];
      final keysI = <String>[...logInfo.map((e) => e.id)];
      final keysE = <String>[...logError.map((e) => e.id)];
      final keysW = <String>[...logWarning.map((e) => e.id)];
      final keysN = <String>[...logNotification.map((e) => e.id)];
      final keysR = <String>[...logRoute.map((e) => e.id)];
      final keysA = <String>[...logAnalytics.map((e) => e.id)];

      for (final log in logs) {
        final logType = log.type;

        switch (logType) {
          case LogType.debug:
            if (!keysD.contains(log.id) || getWithCurrentLogs) {
              logDebugDB.add(log);
            }
            break;
          case LogType.info:
            if (!keysI.contains(log.id) || getWithCurrentLogs) {
              logInfoDB.add(log);
            }
            break;
          case LogType.error:
            if (!keysE.contains(log.id) || getWithCurrentLogs) {
              logErrorDB.add(log);
            }
            break;
          case LogType.warning:
            if (!keysW.contains(log.id) || getWithCurrentLogs) {
              logWarningDB.add(log);
            }
          case LogType.notification:
            if (!keysN.contains(log.id) || getWithCurrentLogs) {
              logNotificationDB.add(log);
            }
          case LogType.route:
            if (!keysR.contains(log.id) || getWithCurrentLogs) {
              logRouteDB.add(log);
            }
          case LogType.analytics:
            if (!keysA.contains(log.id) || getWithCurrentLogs) {
              logAnalyticsDB.add(log);
            }
          default:
            break;
        }
      }

      logDebugDB = sortLogsByTime(logDebugDB);
      logInfoDB = sortLogsByTime(logInfoDB);
      logErrorDB = sortLogsByTime(logErrorDB);
      logWarningDB = sortLogsByTime(logWarningDB);
      logAnalyticsDB = sortLogsByTime(logAnalyticsDB);
      logRouteDB = sortLogsByTime(logRouteDB);
      logNotificationDB = sortLogsByTime(logNotificationDB);
    }
  }

  Future<void> _clearLogs(LogType type) async {
    if (LogsModeController.instance.isFromCurrentSession) {
      _clearLogsByType(type);
    } else if (_useDB) {
      await _clearDBLogsByType(type);
    }

    onLogsClear?.call();
  }

  void _clearLogsByType(LogType type) {
    switch (type) {
      case LogType.debug:
        logDebug.clear();
        break;
      case LogType.info:
        logInfo.clear();
        break;
      case LogType.error:
        logError.clear();
        break;
      case LogType.warning:
        logWarning.clear();
        break;
      case LogType.route:
        logRoute.clear();
        break;
      case LogType.notification:
        logNotification.clear();
        break;
      case LogType.analytics:
        logAnalytics.clear();
        break;
      default:
    }
  }

  Future<void> _clearDBLogsByType(LogType type) async {
    switch (type) {
      case LogType.debug:
        logDebugDB.clear();
        break;
      case LogType.info:
        logInfoDB.clear();
        break;
      case LogType.error:
        logErrorDB.clear();
        break;
      case LogType.warning:
        logWarningDB.clear();
        break;
      case LogType.route:
        logRouteDB.clear();
        break;
      case LogType.notification:
        logNotificationDB.clear();
        break;
      case LogType.analytics:
        logAnalyticsDB.clear();
        break;
      default:
    }
  }

  void _clearAllDBLogs() {
    logDebugDB.clear();
    logInfoDB.clear();
    logErrorDB.clear();
    logRouteDB.clear();
    logNotificationDB.clear();
    logWarningDB.clear();
    logAnalyticsDB.clear();
  }
}
