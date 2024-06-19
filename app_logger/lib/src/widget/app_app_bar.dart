import 'package:app_logger/src/res/colors.dart';
import 'package:app_logger/src/res/styles.dart';
import 'package:app_logger/src/widget/app_back_button.dart';
import 'package:flutter/material.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({
    this.title = '',
    this.titleWidget,
    this.showBackButton,
    this.backButtonColor,
    this.onBackPressed,
    this.actions,
    this.reverse = false,
    this.centerTitle = true,
    super.key,
  });

  final String title;
  final Widget? titleWidget;
  final bool centerTitle;
  final bool reverse;
  final bool? showBackButton;
  final Color? backButtonColor;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
        centerTitle: centerTitle,
        automaticallyImplyLeading: false,
        leading: AppBackButton(
          color: backButtonColor,
          showBackButton: showBackButton,
          onPressed: onBackPressed,
        ),
        title: titleWidget ??
            Text(
              title,
              style: CRStyle.subtitle1BlackSemiBold17,
            ),
        elevation: 0,
        backgroundColor: CRLoggerColors.backgroundGrey,
        actions: actions,
      );
}
