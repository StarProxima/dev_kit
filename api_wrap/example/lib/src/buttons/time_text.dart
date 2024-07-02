import 'package:flutter/material.dart';

class TimeText extends StatelessWidget {
  const TimeText(this.duration, {super.key});

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${duration.inSeconds}'.padLeft(2, '0')),
        const Text(':'),
        Text(
          '${duration.inMilliseconds % Duration.millisecondsPerSecond}'
              .padLeft(3, '0'),
        ),
      ],
    );
  }
}
