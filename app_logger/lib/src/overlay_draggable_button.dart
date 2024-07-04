import 'dart:async';
import 'dart:math';

import 'package:app_logger/src/app_logger_helper.dart';
import 'package:app_logger/src/res/colors.dart';
import 'package:app_logger/src/res/theme.dart';
import 'package:app_logger/src/widget/build_number.dart';
import 'package:flutter/material.dart';

/// Key to access the pop-up menu widget
final popupButtonKey = GlobalKey<PopupMenuButtonState>();

class DraggableButtonWidget extends StatefulWidget {
  const DraggableButtonWidget({
    required this.leftPos,
    required this.topPos,
    required this.onLoggerOpen,
    this.title = 'log',
    this.btnSize = 36,
    super.key,
  });

  final double leftPos;
  final double topPos;
  final String title;
  final double btnSize;
  final Function(BuildContext context) onLoggerOpen;

  @override
  _DraggableButtonWidgetState createState() => _DraggableButtonWidgetState();
}

class _DraggableButtonWidgetState extends State<DraggableButtonWidget> {
  static const spaceForBuildNumberText = 24.0;
  late double left = widget.leftPos;
  late double top = widget.topPos;
  double screenWidth = 0;
  double screenHeight = 0;

  bool isShow = true;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    /// Round

    /// Calculating offset limits

    left = max(left, 1);
    left = min(screenWidth - widget.btnSize - 10, left);

    top = max(top, 1);
    top = min(top, screenHeight - widget.btnSize - 10);

    return Container(
      alignment: Alignment.topLeft,
      margin: EdgeInsets.only(left: left, top: top),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.btnSize / 2),
        child: Opacity(
          opacity: isShow ? 0.7 : 0,
          child: IgnorePointer(
            ignoring: !isShow,
            child: Material(
              child: Theme(
                data: loggerTheme,
                child: GestureDetector(
                  onTap: () => _defaultClick(context),
                  onLongPress: _onPressDraggableButton,
                  onDoubleTap: _onPressDraggableButton,
                  onPanUpdate: _dragUpdate,
                  child: Container(
                    width: widget.btnSize + spaceForBuildNumberText,
                    height: widget.btnSize,
                    color: CRLoggerColors.primaryColor,
                    child: Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 2,
                        children: [
                          ValueListenableBuilder(
                            valueListenable:
                                AppLoggerHelper.instance.loggerShowingNotifier,
                            //ignore:prefer-trailing-comma
                            builder: (context, loggerShowing, child) {
                              return Icon(
                                loggerShowing
                                    ? Icons.visibility_off
                                    : Icons.bug_report,
                                color: Colors.white,
                                size: 20,
                              );
                            },
                          ),
                          const BuildNumber(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _defaultClick(BuildContext context) async {
    setState(() {
      if (AppLoggerHelper.instance.isLoggerShowing) {
        AppLoggerHelper.instance.hideLogger();
      } else {
        widget.onLoggerOpen(context);
        AppLoggerHelper.instance.showLogger();
      }
    });
  }

  void _onPressDraggableButton() {
    if (!AppLoggerHelper.instance.isLoggerShowing) {
      setState(() {
        isShow = false;
      });
      popupButtonKey.currentState?.showButtonMenu();
    }
  }

  void _dragUpdate(DragUpdateDetails detail) {
    setState(() {
      final offset = detail.delta;
      left = left + offset.dx;
      top = top + offset.dy;
    });
  }
}
