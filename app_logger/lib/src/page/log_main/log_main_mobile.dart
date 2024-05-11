import 'package:app_logger/app_logger.dart';
import 'package:app_logger/generated/assets.dart';
import 'package:app_logger/src/app_logger_helper.dart';
import 'package:app_logger/src/controllers/logs_mode.dart';
import 'package:app_logger/src/controllers/logs_mode_controller.dart';
import 'package:app_logger/src/extensions/do_post_frame.dart';
import 'package:app_logger/src/extensions/extensions.dart';
import 'package:app_logger/src/managers/log_manager.dart';
import 'package:app_logger/src/page/http_logs/http_logs_page.dart';
import 'package:app_logger/src/page/log_main/widgets/mobile_header_widget.dart';
import 'package:app_logger/src/page/logs/log_local_detail_page.dart';
import 'package:app_logger/src/page/logs/log_page.dart';
import 'package:app_logger/src/page/widgets/popup_menu.dart';
import 'package:app_logger/src/res/colors.dart';
import 'package:app_logger/src/res/styles.dart';
import 'package:app_logger/src/widget/app_app_bar.dart';
import 'package:app_logger/src/widget/options_buttons.dart';
import 'package:flutter/material.dart';

class MainLogMobilePage extends StatefulWidget {
  const MainLogMobilePage({
    required this.onLoggerClose,
    super.key,
    this.debugScreen,
  });

  final Widget? debugScreen;
  final VoidCallback onLoggerClose;

  @override
  State<StatefulWidget> createState() => MainLogMobilePageState();
}

class MainLogMobilePageState extends State<MainLogMobilePage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.debugScreen == null) {
      return LogsPage(onLoggerClose: widget.onLoggerClose);
    }

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          LogsPage(onLoggerClose: widget.onLoggerClose),
          widget.debugScreen!,
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.text_snippet),
            label: 'Logs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.error_outlined),
            label: 'Debug',
          ),
        ],
      ),
    );
  }
}

class LogsPage extends StatefulWidget {
  const LogsPage({
    required this.onLoggerClose,
    super.key,
  });

  final VoidCallback onLoggerClose;

  static void cleanLogs({bool clearDB = false}) {
    LogManager.instance.clean(cleanDB: clearDB);
  }

  static void cleanHttpLogs() {
    HttpLogManager.instance.cleanAllLogs(cleanDB: true);
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
  _LogsPageState createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  final _pageController = PageController();
  final _logsMode = LogsModeController.instance.logMode;

  final _popupKey = GlobalKey<PopupMenuButtonState>();
  final _navKey = GlobalKey<OptionsButtonsState>();

  final _httpLogKey = GlobalKey<HttpLogsPageState>();
  final _debugLogKey = GlobalKey<LogPageState>();
  final _infoLogKey = GlobalKey<LogPageState>();
  final _errorLogKey = GlobalKey<LogPageState>();
  final _warningLogKey = GlobalKey<LogPageState>();
  final _routeLogKey = GlobalKey<LogPageState>();
  final _notificationLogKey = GlobalKey<LogPageState>();
  final _analyticsLogKey = GlobalKey<LogPageState>();

  late List<Widget> tabPages;

  final ValueNotifier<LogType> _currentLogType = ValueNotifier(LogType.request);

  @override
  void initState() {
    super.initState();
    tabPages = [
      HttpLogsPage(key: _httpLogKey),
      LogPage(key: _debugLogKey, logType: LogType.debug),
      LogPage(key: _infoLogKey, logType: LogType.info),
      LogPage(key: _errorLogKey, logType: LogType.error),
      LogPage(key: _warningLogKey, logType: LogType.warning),
      LogPage(key: _routeLogKey, logType: LogType.route),
      LogPage(key: _notificationLogKey, logType: LogType.notification),
      LogPage(key: _analyticsLogKey, logType: LogType.analytics),
    ];
    _pageController.addListener(_onPageChanged);
    LogManager.instance.logToastNotifier.addListener(_openLogDetails);
    WidgetsBinding.instance.addPostFrameCallback((_) => _openLogDetails());
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    LogManager.instance.logToastNotifier.removeListener(_openLogDetails);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppLoggerHelper.instance.theme,
      child: Scaffold(
        backgroundColor: CRLoggerColors.backgroundGrey,
        appBar: AppAppBar(
          titleWidget: ValueListenableBuilder(
            valueListenable: _logsMode,

            //ignore: prefer-trailing-comma
            builder: (_, __, ___) => Text(
              _logsMode.value.appBarTitle,
              style: CRStyle.subtitle1BlackSemiBold17,
            ),
          ),
          onBackPressed: widget.onLoggerClose,
          showBackButton: true,
          actions: [
            PopupMenu(
              popupKey: _popupKey,
              child: IconButton(
                onPressed: () => _popupKey.currentState?.showButtonMenu(),
                icon: ImageExt.fromPackage(CRLoggerAssets.assetsIcMenu),
              ),
            ),
          ],
        ),
        body: Container(
          color: CRLoggerColors.backgroundGrey,
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            children: [
              Column(
                children: [
                  OptionsButtons(
                    key: _navKey,
                    titles: [
                      LogType.request.emoji,
                      LogType.debug.emoji,
                      LogType.info.emoji,
                      LogType.error.emoji,
                      LogType.warning.emoji,
                      LogType.route.emoji,
                      LogType.notification.emoji,
                      LogType.analytics.emoji,
                    ],
                    onSelected: _onOptionSelected,
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder(
                    valueListenable: _currentLogType,
                    builder: (_, LogType value, __) {
                      return MobileHeaderWidget(
                        onClear: _onClear,
                        onAllClear: _onAllClear,
                        label: value.label,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  children: tabPages,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onAllClear() {
    LogManager.instance.clean(cleanDB: _logsMode.value == LogsMode.fromDB);
    _updatePages();
  }

  void _onClear() {
    switch (_currentLogType.value) {
      case LogType.debug:
        LogManager.instance.cleanDebug();
        break;
      case LogType.info:
        LogManager.instance.cleanInfo();
        break;
      case LogType.error:
        LogManager.instance.cleanError();
        break;
      case LogType.request:
        HttpLogManager.instance.cleanHTTP();
        break;
      case LogType.warning:
        LogManager.instance.cleanWarning();
        break;
      case LogType.route:
        LogManager.instance.cleanRoute();
        break;
      case LogType.notification:
        LogManager.instance.cleanNotification();
        break;
      case LogType.analytics:
        LogManager.instance.cleanAnalytics();
        break;
      default:
    }
    _updatePages();
  }

  void _updatePages() {
    doPostFrame(() {
      (tabPages[_getIndexByLogType(_currentLogType.value)].key as GlobalKey)
          .currentState
          // ignore: no-empty-block
          ?.setState(() {});
    });
  }

  LogType _getLogTypeByIndex(int index) {
    return switch (index) {
      0 => LogType.request,
      1 => LogType.debug,
      2 => LogType.info,
      3 => LogType.error,
      4 => LogType.warning,
      5 => LogType.route,
      6 => LogType.notification,
      7 => LogType.analytics,
      _ => LogType.debug,
    };
  }

  int _getIndexByLogType(LogType logType) {
    return switch (logType) {
      LogType.info => 2,
      LogType.debug => 1,
      LogType.warning => 4,
      LogType.error => 3,
      LogType.request => 0,
      LogType.route => 5,
      LogType.notification => 6,
      LogType.analytics => 7,
      _ => 0,
    };
  }

  void _onPageChanged() {
    _currentLogType.value =
        _getLogTypeByIndex(_pageController.page?.round() ?? 0);
    _navKey.currentState?.change(_getIndexByLogType(_currentLogType.value));
  }

  void _onOptionSelected(int index) {
    _currentLogType.value =
        _getLogTypeByIndex(_pageController.page?.round() ?? 0);
    _pageController.jumpToPage(index);
  }

  /// Opens a tab according to the type of log
  /// Opens the log details page
  Future<void> _openLogDetails() async {
    final log = LogManager.instance.logToastNotifier.value;
    final logType = log?.type as LogType?;

    if (logType != null && log != null) {
      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (ctx) => LogLocalDetailPage(
            logBean: log,
            logType: logType,
          ),
        ),
        (Route<dynamic> route) => route.settings.name == '/',
      );

      _pageController.jumpToPage(_getIndexByLogType(logType));
      LogManager.instance.logToastNotifier.value = null;
    }
  }
}
