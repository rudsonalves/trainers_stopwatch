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
import 'package:trainers_stopwatch/common/singletons/app_settings.dart';

import 'trainings_page.dart';

class TrainingsOverlay extends StatefulWidget {
  const TrainingsOverlay({super.key});

  static const routeName = '/trainings';

  @override
  State<TrainingsOverlay> createState() => _TrainingsOverlayState();
}

class _TrainingsOverlayState extends State<TrainingsOverlay> {
  late final List<OnboardingStep> steps;
  final app = AppSettings.instance;

  @override
  void initState() {
    super.initState();

    initSteps();
  }

  void initSteps() {
    final baseColor = const Color(0xFF976700).withOpacity(0.9);

    steps = [
      OnboardingStep(
        focusNode: FocusNode(),
        titleText: 'tutorialTPTitle01'.tr(),
        bodyText: 'tutorialTPMsg01'.tr(),
        fullscreen: false,
        overlayShape: const CircleBorder(),
        overlayColor: baseColor,
      ),
      OnboardingStep(
        focusNode: app.focusNodes[23],
        titleText: 'tutorialTPTitle02a'.tr(),
        bodyText: 'tutorialTPMsg02a'.tr(),
        overlayColor: baseColor,
        overlayShape: const CircleBorder(),
        overlayBehavior: HitTestBehavior.translucent,
        showPulseAnimation: true,
        onTapCallback: (area, next, close) {
          if (area == TapArea.hole) {
            next();
          }
        },
      ),
      OnboardingStep(
        focusNode: app.focusNodes[23],
        titleText: 'tutorialTPTitle02'.tr(),
        bodyText: 'tutorialTPMsg02'.tr(),
        overlayColor: baseColor,
        overlayShape: const CircleBorder(),
        overlayBehavior: HitTestBehavior.translucent,
        showPulseAnimation: true,
        onTapCallback: (area, next, close) {
          if (area == TapArea.hole) {
            next();
          }
        },
      ),
      OnboardingStep(
        focusNode: app.focusNodes[24],
        titleText: 'tutorialTPTitle03'.tr(),
        bodyText: 'tutorialTPMsg03'.tr(),
        overlayColor: baseColor,
        fullscreen: true,
        showPulseAnimation: true,
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {
          if (area == TapArea.hole) {
            next();
          }
        },
      ),
      OnboardingStep(
        focusNode: app.focusNodes[25],
        titleText: 'tutorialTPTitle04'.tr(),
        bodyText: 'tutorialTPMsg04'.tr(),
        overlayColor: baseColor,
        fullscreen: true,
      ),
      OnboardingStep(
        focusNode: app.focusNodes[26],
        titleText: 'tutorialTPTitle05'.tr(),
        bodyText: 'tutorialTPMsg05'.tr(),
        overlayColor: baseColor,
        overlayShape: const CircleBorder(),
        fullscreen: false,
      ),
      OnboardingStep(
        focusNode: app.focusNodes[27],
        titleText: 'tutorialTPTitle06'.tr(),
        bodyText: 'tutorialTPMsg06'.tr(),
        overlayColor: baseColor,
        overlayShape: const CircleBorder(),
        fullscreen: false,
      ),
      OnboardingStep(
        focusNode: app.focusNodes[28],
        titleText: 'tutorialTPTitle07'.tr(),
        bodyText: 'tutorialTPMsg07'.tr(),
        overlayColor: baseColor,
        overlayShape: const CircleBorder(),
        fullscreen: false,
      ),
      onboardingStepMessage(
        baseColor: baseColor,
        title: 'tutorialTPTitle08'.tr(),
        body: 'tutorialTPMsg08'.tr(),
        imagePath: 'assets/images/training_edit.png',
      ),
      onboardingStepMessage(
        baseColor: baseColor,
        title: 'tutorialTPTitle09'.tr(),
        body: 'tutorialTPMsg09'.tr(),
        imagePath: 'assets/images/training_delete.png',
      ),
    ];
  }

  OnboardingStep onboardingStepMessage({
    required Color baseColor,
    required String title,
    required String body,
    required String imagePath,
  }) {
    return OnboardingStep(
      focusNode: FocusNode(),
      titleText: title,
      bodyText: body,
      overlayShape: const CircleBorder(),
      fullscreen: true,
      onTapCallback: (area, next, close) => next(),
      stepBuilder: (context, renderInfo) => SizedBox(
        child: Material(
          child: Container(
            width: renderInfo.size.width * 0.9,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: baseColor.withOpacity(0.9),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    renderInfo.titleText,
                    style: renderInfo.titleStyle,
                  ),
                  const SizedBox(width: 40),
                  Text(
                    renderInfo.bodyText,
                    style: renderInfo.bodyStyle,
                  ),
                  Image.asset(imagePath),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Onboarding(
      key: GlobalKey<OnboardingState>(),
      steps: steps,
      child: const TrainingsPage(),
    );
  }
}
