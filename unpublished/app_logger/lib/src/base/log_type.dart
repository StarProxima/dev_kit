import 'package:proxima_logger/proxima_logger.dart';

enum LogType implements ILogType {
  info(
    label: 'info',
    emoji: '💡',
    ansiPen: AnsiPen.none(),
  ),
  debug(
    label: 'debug',
    emoji: '🐛',
    ansiPen: AnsiPen.green(),
  ),
  warning(
    label: 'warning',
    emoji: '⚠️',
    ansiPen: AnsiPen.orange(),
  ),
  error(
    label: 'error',
    emoji: '⛔',
    ansiPen: AnsiPen.red(),
  ),
  wtf(
    label: 'wtf',
    emoji: '👾',
    ansiPen: AnsiPen.purple(),
  ),
  request(
    label: 'request',
    emoji: '📡',
    ansiPen: AnsiPen.blue(),
  ),
  response(
    label: 'response',
    emoji: '🔭',
    ansiPen: AnsiPen.lightBlue(),
  ),
  route(
    label: 'route',
    emoji: '🔀',
    ansiPen: AnsiPen.cyan(),
  ),
  notification(
    label: 'push',
    emoji: '🔔',
    ansiPen: AnsiPen.yellow(),
  ),
  analytics(
    label: 'analytics',
    emoji: '📈',
    ansiPen: AnsiPen.pink(),
  ),
  ;

  const LogType({
    required this.label,
    required this.emoji,
    required this.ansiPen,
    // ignore: unused_element
    this.ansiPenOnBackground = const AnsiPen.black(),
  });

  @override
  final String label;
  @override
  final String emoji;
  @override
  final AnsiPen ansiPen;
  @override
  final AnsiPen ansiPenOnBackground;
}
