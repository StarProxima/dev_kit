import 'package:app_logger/app_logger.dart';
import 'package:app_logger/src/app_logger_helper.dart';
import 'package:app_logger/src/managers/log_manager.dart';
import 'package:app_logger/src/page/log_main/log_main_mobile.dart';
import 'package:app_logger/src/page/log_main/log_main_web.dart';
import 'package:app_logger/src/widget/adaptive_layout/adaptive_layout_widget.dart';
import 'package:flutter/material.dart';

class MainLogPage extends StatefulWidget {
  const MainLogPage({
    required this.navigationKey,
    required this.onLoggerClose,
    super.key,
    this.debugScreen,
  });

  final GlobalKey<NavigatorState> navigationKey;
  final VoidCallback onLoggerClose;
  final Widget? debugScreen;

  static void cleanLogs() {
    cleanDebug();
    cleanError();
    cleanInfo();
    cleanHttpLogs();
    cleanAnalytics();
    cleanNotification();
    cleanRoute();
    cleanWarning();
  }

  static void cleanHttpLogs() {
    HttpLogManager.instance.cleanAllLogs();
  }

  static void cleanDebug() {
    LogManager.instance.cleanDebug();
  }

  static void cleanInfo() {
    LogManager.instance.cleanInfo();
  }

  static void cleanError() {
    LogManager.instance.cleanError();
  }

  static void cleanWarning() {
    LogManager.instance.cleanWarning();
  }

  static void cleanAnalytics() {
    LogManager.instance.cleanAnalytics();
  }

  static void cleanRoute() {
    LogManager.instance.cleanRoute();
  }

  static void cleanNotification() {
    LogManager.instance.cleanNotification();
  }

  @override
  _MainLogPageState createState() => _MainLogPageState();
}

class _MainLogPageState extends State<MainLogPage> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppLoggerHelper.instance.theme,
      child: ValueListenableBuilder<bool>(
        valueListenable: AppLoggerHelper.instance.loggerShowingNotifier,
        // ignore: prefer-trailing-comma
        builder: (_, showLogger, __) => Offstage(
          offstage: !showLogger,
          child: Navigator(
            key: widget.navigationKey,
            onGenerateRoute: _onGenerateRoute,
          ),
        ),
      ),
    );
  }

  Route? _onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute<dynamic>(
      builder: (context) => AdaptiveLayoutWidget(
        mobileLayoutWidget: MainLogMobilePage(
          onLoggerClose: widget.onLoggerClose,
          debugScreen: widget.debugScreen,
        ),
        webLayoutWidget: MainLogWebPage(
          onLoggerClose: widget.onLoggerClose,
        ),
      ),
      settings: settings,
    );
  }
}
