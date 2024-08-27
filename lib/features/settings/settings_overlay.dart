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

import '../../common/singletons/app_settings.dart';
import 'settings_page.dart';

class SettingsOverlay extends StatefulWidget {
  const SettingsOverlay({super.key});

  static const routeName = '/settings';

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay> {
  late final List<OnboardingStep> steps;
  final app = AppSettings.instance;

  @override
  void initState() {
    super.initState();

    initSteps();
  }

  void initSteps() {
    final baseColor = Colors.indigo.withOpacity(0.9);

    steps = [
      OnboardingStep(
        focusNode: FocusNode(),
        titleText: 'tutorSettingsTitle01'.tr(),
        bodyText: 'tutorSettingsMsg01'.tr(),
        fullscreen: false,
        overlayColor: baseColor,
        overlayShape: const CircleBorder(),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[19],
        titleText: 'tutorSettingsTitle02'.tr(),
        bodyText: 'tutorSettingsMsg02'.tr(),
        fullscreen: false,
        overlayColor: baseColor,
        overlayShape: const CircleBorder(),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[20],
        titleText: 'tutorSettingsTitle03'.tr(),
        bodyText: 'tutorSettingsMsg03'.tr(),
        fullscreen: false,
        overlayColor: baseColor,
        overlayShape: const CircleBorder(),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[21],
        titleText: 'tutorSettingsTitle04'.tr(),
        bodyText: 'tutorSettingsMsg04'.tr(),
        fullscreen: false,
        overlayColor: baseColor,
        overlayShape: const CircleBorder(),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[22],
        titleText: 'tutorSettingsTitle05'.tr(),
        bodyText: 'tutorSettingsMsg05'.tr(),
        fullscreen: true,
        overlayColor: baseColor,
        onTapCallback: (area, next, close) {
          close();
          app.disableTutorial();
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Onboarding(
      key: GlobalKey<OnboardingState>(),
      steps: steps,
      child: const SettingsPage(),
    );
  }
}
