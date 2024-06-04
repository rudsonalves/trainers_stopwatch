import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:onboarding_overlay/onboarding_overlay.dart';
import 'package:trainers_stopwatch/common/singletons/app_settings.dart';
import 'package:trainers_stopwatch/features/settings/settings_page.dart';

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
