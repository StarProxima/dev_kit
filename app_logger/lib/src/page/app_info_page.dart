import 'package:app_logger/src/app_logger.dart';
import 'package:app_logger/src/app_logger_helper.dart';
import 'package:app_logger/src/page/widgets/app_info_item.dart';
import 'package:app_logger/src/res/colors.dart';
import 'package:app_logger/src/res/styles.dart';
import 'package:app_logger/src/widget/app_app_bar.dart';
import 'package:flutter/material.dart';

class AppInfoPage extends StatelessWidget {
  const AppInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final packageInfo = AppLoggerHelper.instance.packageInfo;
    final packageName = packageInfo.packageName;
    final version = packageInfo.version;
    final buildNumber = packageInfo.buildNumber;
    final customInfoItems = AppLoggerInitializer.instance.appInfo.entries;

    return Theme(
      data: AppLoggerHelper.instance.theme,
      child: Scaffold(
        backgroundColor: CRLoggerColors.backgroundGrey,
        appBar: const AppAppBar(title: 'App info'),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          children: [
            /// Package name
            RichText(
              text: TextSpan(
                text: 'Package name: ',
                style: CRStyle.bodyBlackSemiBold14,
                children: [
                  TextSpan(
                    text: packageName,
                    style: CRStyle.bodyBlackRegular14,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            /// Version
            RichText(
              textDirection: TextDirection.ltr,
              text: TextSpan(
                text: 'Version: ',
                style: CRStyle.bodyBlackSemiBold14,
                children: [
                  TextSpan(
                    text: '$version+$buildNumber',
                    style: CRStyle.bodyBlackRegular14,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            /// Custom app info
            if (customInfoItems.isNotEmpty) ...[
              const Divider(),
              ...customInfoItems.map(
                (item) {
                  return AppInfoItem(
                    name: item.key,
                    value: item.value,
                  );
                },
              ).toList(),
            ],
          ],
        ),
      ),
    );
  }
}
