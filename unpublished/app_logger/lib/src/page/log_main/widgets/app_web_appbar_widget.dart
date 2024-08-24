import 'package:app_logger/src/page/widgets/popup_menu.dart';
import 'package:app_logger/src/res/styles.dart';
import 'package:flutter/material.dart';

class AppWebAppBar extends StatelessWidget {
  const AppWebAppBar({
    required this.popupKey,
    required this.onLoggerClose,
    super.key,
  });

  final GlobalKey popupKey;
  final VoidCallback onLoggerClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PopupMenu(
            popupKey: popupKey,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(Icons.view_headline),
                  SizedBox(width: 10),
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      'Menu',
                      style: CRStyle.subtitle1BlackSemiBold16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: onLoggerClose,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Text(
                    'Close',
                    style: CRStyle.subtitle1BlackSemiBold16,
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.close),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
