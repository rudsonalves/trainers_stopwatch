import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../common/theme/app_font_style.dart';
import '../../about_page/about_page.dart';
import '../../settings/settings_page.dart';
import '../../trainings_page/trainings_page.dart';

class StopwatchDrawer extends StatelessWidget {
  final Future<void> Function() addStopwatchs;

  const StopwatchDrawer({
    super.key,
    required this.addStopwatchs,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: colorScheme.onPrimary,
            ),
            child: Text(
              'SPDTitle'.tr(),
              style: AppFontStyle.roboto20SemiBold,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people_alt_rounded),
            title: Text('SPDItemAthletes'.tr()),
            onTap: () async {
              Navigator.pop(context);
              addStopwatchs();
            },
          ),
          ListTile(
            leading: const Icon(Icons.directions_run),
            title: Text('SPDItemTrainings'.tr()),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, TrainingsPage.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text('SPDItemSettings'.tr()),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, SettingsPage.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text('SPDItemAbout'.tr()),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AboutPage.routeName);
            },
          ),
        ],
      ),
    );
  }
}
