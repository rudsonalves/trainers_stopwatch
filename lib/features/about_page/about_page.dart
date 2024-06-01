import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../common/app_info.dart';
import '../../common/theme/app_font_style.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  static const routeName = '/about';

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    const double height = 30;
    final primary = Theme.of(context).colorScheme.primary;
    const appPage = 'https://rralves.dev.br/en/trainers-stopwatch-en/';

    return Scaffold(
      appBar: AppBar(
        title: Text('SPDItemAbout'.tr()),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              AppInfo.name,
              style: AppFontStyle.roboto20SemiBold,
              textAlign: TextAlign.center,
            ),
            Text(
              'APVersion'.tr(args: [AppInfo.version]),
              style: AppFontStyle.roboto16SemiBold.copyWith(
                color: primary,
              ),
            ),
            const SizedBox(height: height * 2),
            Text(
              'APDeveloperPage'.tr(),
              style: AppFontStyle.roboto16SemiBold,
              textAlign: TextAlign.center,
            ),
            const TextButton(
              onPressed: AppInfo.launchMailto,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.email,
                  ),
                  SizedBox(width: 6),
                  Text(
                    AppInfo.email,
                    style: AppFontStyle.roboto16SemiBold,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: height),
            Text(
              'APPrivacyPolicy'.tr(),
              style: AppFontStyle.roboto16SemiBold,
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.public,
                  color: primary,
                ),
                const SizedBox(width: 6),
                TextButton(
                  onPressed: () => AppInfo.launchUrl(AppInfo.privacyPolicyUrl),
                  child: Text(
                    AppInfo.privacyPolicyUrl.replaceAll('https://', ''),
                    style: AppFontStyle.roboto16SemiBold,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: height),
            Text(
              'APAppPage'.tr(),
              style: AppFontStyle.roboto16SemiBold,
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.public,
                  color: primary,
                ),
                const SizedBox(width: 6),
                TextButton(
                  onPressed: () => AppInfo.launchUrl(appPage),
                  child: Text(
                    appPage.replaceAll('https://', ''),
                    style: AppFontStyle.roboto16SemiBold,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
