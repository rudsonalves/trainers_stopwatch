// Copyright (C) 2024 Rudson Alves
// 
// This file is part of trainers_stopwatch.
// 
// trainers_stopwatch is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// trainers_stopwatch is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with trainers_stopwatch.  If not, see <https://www.gnu.org/licenses/>.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:onboarding_overlay/onboarding_overlay.dart';

import '../../../common/singletons/app_settings.dart';
import '../../../common/theme/app_font_style.dart';
import '../../about_page/about_page.dart';
import '../../settings/settings_overlay.dart';
import '../../trainings_page/trainings_overlay.dart';

class StopwatchDrawer extends StatelessWidget {
  final Future<void> Function() addStopwatchs;
  final List<FocusNode> focusNodes;

  const StopwatchDrawer({
    super.key,
    required this.addStopwatchs,
    required this.focusNodes,
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
              image: const DecorationImage(
                image: AssetImage('assets/images/running.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                'SPDTitle'.tr(),
                style: AppFontStyle.roboto20SemiBold,
              ),
            ),
          ),
          ListTile(
            focusNode: focusNodes[2],
            leading: const Icon(Icons.people_alt_rounded),
            title: Text('SPDItemUsers'.tr()),
            onTap: () async {
              Navigator.pop(context);
              addStopwatchs();
            },
          ),
          ListTile(
            focusNode: focusNodes[3],
            leading: const Icon(Icons.directions_run),
            title: Text('SPDItemTrainings'.tr()),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, TrainingsOverlay.routeName);
            },
          ),
          ListTile(
            focusNode: focusNodes[4],
            leading: const Icon(Icons.settings),
            title: Text('SPDItemSettings'.tr()),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, SettingsOverlay.routeName);
            },
          ),
          ListTile(
            focusNode: focusNodes[6],
            leading: const Icon(Icons.info_outline),
            title: Text('SPDItemAbout'.tr()),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AboutPage.routeName);
            },
          ),
          ListTile(
            focusNode: focusNodes[5],
            leading: const Icon(Icons.question_mark),
            title: const Text('Tutorial'),
            onTap: () {
              Navigator.pop(context);
              final overlay = Onboarding.of(context);
              if (overlay != null) {
                AppSettings.instance.tutorialOn = true;
                overlay.show();
              }
            },
          ),
        ],
      ),
    );
  }
}
