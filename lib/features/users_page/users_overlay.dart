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
import 'users_page.dart';

class UsersOverlay extends StatefulWidget {
  const UsersOverlay({super.key});

  static const routeName = '/users';

  @override
  State<UsersOverlay> createState() => _UsersOverlayState();
}

class _UsersOverlayState extends State<UsersOverlay> {
  late final List<OnboardingStep> steps;
  final app = AppSettings.instance;

  @override
  void initState() {
    super.initState();

    initSteps();
  }

  void initSteps() {
    final baseColor = Colors.green.withOpacity(0.9);

    steps = [
      OnboardingStep(
        focusNode: FocusNode(),
        titleText: 'tutorUserTitle01'.tr(),
        bodyText: 'tutorUserMsg01'.tr(),
        fullscreen: false,
        overlayShape: const CircleBorder(),
        overlayColor: baseColor,
      ),
      OnboardingStep(
        focusNode: app.focusNodes[8],
        titleText: 'tutorUserTitle02'.tr(),
        bodyText: 'tutorUserMsg02'.tr(),
        fullscreen: false,
        shape: const CircleBorder(),
        overlayShape: const CircleBorder(),
        overlayColor: baseColor,
        showPulseAnimation: true,
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {
          if (area == TapArea.hole) {
            close();
          }
        },
      ),
      // Continue...
      OnboardingStep(
        focusNode: app.focusNodes[9],
        titleText: 'tutorUserTitle03'.tr(),
        bodyText: 'tutorUserMsg03'.tr(),
        fullscreen: true,
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
        focusNode: app.focusNodes[9],
        titleText: 'tutorUserTitle04'.tr(),
        bodyText: 'tutorUserMsg04'.tr(),
        fullscreen: false,
        overlayShape: const CircleBorder(),
        overlayColor: baseColor,
      ),
      OnboardingStep(
        focusNode: FocusNode(),
        titleText: 'tutorUserTitle05'.tr(),
        bodyText: 'tutorUserMsg05'.tr(),
        fullscreen: true,
        overlayColor: Colors.transparent,
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {},
        stepBuilder: (context, renderInfo) => SizedBox(
          child: Material(
            child: Container(
              width: renderInfo.size.width * 0.9,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: baseColor,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      renderInfo.titleText,
                      style: renderInfo.titleStyle,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      renderInfo.bodyText,
                      style: renderInfo.bodyStyle,
                    ),
                    OverflowBar(
                      children: [
                        FilledButton.tonal(
                          onPressed: renderInfo.nextStep,
                          child: const Text('Tutorial'),
                        ),
                        FilledButton.tonal(
                          onPressed: () {
                            renderInfo.close();
                            app.tutorialOn = false;
                          },
                          child: const Text('close'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[10],
        titleText: 'tutorUserTitle06'.tr(),
        bodyText: 'tutorUserMsg06'.tr(),
        fullscreen: false,
        overlayColor: baseColor,
        shape: const CircleBorder(),
        overlayShape: const CircleBorder(),
        showPulseAnimation: true,
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {
          if (area == TapArea.hole) {
            close();
          }
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Onboarding(
      key: GlobalKey<OnboardingState>(),
      steps: steps,
      child: const UsersPage(),
    );
  }
}
