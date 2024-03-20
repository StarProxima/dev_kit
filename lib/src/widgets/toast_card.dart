// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../dev_kit.dart';

enum ToastType {
  success,
  info,
  warning,
  error,
}

class ToastCard extends StatefulHookConsumerWidget {
  const ToastCard({
    super.key,
    required this.type,
    required this.duration,
    required this.onDismissed,
    this.text,
    this.title,
    this.debugText,
    this.isDebug = false,
    this.decoration,
  });

  final ToastType type;
  final Duration duration;
  final VoidCallback onDismissed;

  final Text? text;
  final Text? title;
  final Text? debugText;
  final bool isDebug;

  final Decoration? decoration;

  @override
  ConsumerState<ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends ConsumerState<ToastCard> {
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    final title = widget.title;
    final text = widget.text;
    final debugText = widget.debugText;
    final isDebug = widget.isDebug;
    final duration = widget.duration;
    final decoration = widget.decoration;

    final scaleAnimationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 150),
    );

    void setTimerToHide({bool immediately = false}) {
      timer?.cancel();
      timer = Timer(immediately ? Duration.zero : duration, () {
        if (!mounted) return;
        scaleAnimationController.reverse();
        Future.delayed(
          scaleAnimationController.reverseDuration!,
          () {
            if (mounted) {
              widget.onDismissed();
            }
          },
        );
      });
    }

    useEffect(
      () {
        scaleAnimationController.forward();
        setTimerToHide();
        return timer?.cancel;
      },
      const [],
    );

    final debugTextAnimationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    void openCloseCard() {
      if (debugTextAnimationController.isCompleted) {
        debugTextAnimationController.reverse();
        setTimerToHide();
      } else if (widget.debugText != null) {
        debugTextAnimationController.forward();
        timer?.cancel();
      }
    }

    const horizontalPadding = EdgeInsets.only(left: 12, right: 8);

    const backgroundColor = Colors.white;
    const textColor = Colors.black;
    final iconColor = switch (widget.type) {
      ToastType.success => Colors.green,
      ToastType.info => Colors.blue,
      ToastType.warning => Colors.yellow,
      ToastType.error => Colors.red,
    };

    return DefaultTextStyle(
      style: const TextStyle(color: textColor),
      child: ScaleTransition(
        scale: scaleAnimationController.drive(
          CurveTween(curve: Curves.easeOutBack),
        ),
        child: GestureDetector(
          onTap: openCloseCard,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: decoration ??
                BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: backgroundColor,
                  border: Border.all(color: textColor.withOpacity(0.2)),
                ),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.8,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: horizontalPadding,
                      child: Row(
                        children: [
                          Icon(
                            switch (widget.type) {
                              ToastType.success => Icons.check_circle_outline,
                              ToastType.info => Icons.info_outline,
                              ToastType.warning => Icons.info_outline,
                              ToastType.error => Icons.cancel_outlined,
                            },
                            color: iconColor,
                          ),
                          const Gap(12),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Gap(12),
                                      if (title != null || isDebug)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 2,
                                          ),
                                          child: Text.rich(
                                            TextSpan(
                                              children: [
                                                if (isDebug)
                                                  const WidgetSpan(
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                        right: 4,
                                                      ),
                                                      child: Icon(
                                                        Icons.bug_report,
                                                        color: textColor,
                                                      ),
                                                    ),
                                                  ),
                                                if (title != null)
                                                  TextSpan(
                                                    text: title.data,
                                                    style: title.style,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      if (text != null) text,
                                      const Gap(12),
                                    ],
                                  ),
                                ),
                                Material(
                                  type: MaterialType.transparency,
                                  child: InkWell(
                                    radius: 50,
                                    borderRadius: BorderRadius.circular(50),
                                    onTap: () =>
                                        setTimerToHide(immediately: true),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.close,
                                        size: 24,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (debugText != null)
                      SizeTransition(
                        sizeFactor: CurvedAnimation(
                          curve: Curves.easeInOut,
                          parent: debugTextAnimationController,
                        ),
                        axisAlignment: -1,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(
                              color: textColor.withOpacity(0.1),
                              thickness: 2,
                              height: 2,
                            ),
                            Padding(
                              padding: horizontalPadding,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  bottom: 4,
                                ),
                                child: debugText,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
