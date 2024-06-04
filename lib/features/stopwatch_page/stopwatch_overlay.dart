import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:onboarding_overlay/onboarding_overlay.dart';
import 'package:trainers_stopwatch/common/singletons/app_settings.dart';

import 'stopwatch_page.dart';

class StopwatchOverlay extends StatefulWidget {
  const StopwatchOverlay({super.key});

  static const routeName = '/stopwatchs';

  @override
  State<StopwatchOverlay> createState() => _StopwatchOverlayState();
}

class _StopwatchOverlayState extends State<StopwatchOverlay> {
  late final List<OnboardingStep> steps;
  final app = AppSettings.instance;

  @override
  void initState() {
    super.initState();

    initSteps();
  }

  void initSteps() {
    steps = [
      OnboardingStep(
        focusNode: FocusNode(),
        titleText: 'tutorSWTitle01'.tr(),
        bodyText: 'tutorSWMsg01'.tr(),
        fullscreen: false,
        overlayColor: Colors.blue.withOpacity(0.9),
        shape: const CircleBorder(),
        overlayShape: const CircleBorder(),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[0],
        titleText: 'tutorSWTitle02'.tr(),
        bodyText: 'tutorSWMsg02'.tr(),
        fullscreen: false,
        overlayColor: Colors.blue.withOpacity(0.9),
        shape: const CircleBorder(),
        overlayShape: const CircleBorder(),
        showPulseAnimation: true,
        overlayBehavior: HitTestBehavior.deferToChild,
      ),
      OnboardingStep(
        focusNode: app.focusNodes[1],
        titleText: 'tutorSWTitle03'.tr(),
        bodyText: 'tutorSWMsg03'.tr(),
        overlayColor: Colors.blueAccent.withOpacity(0.9),
        fullscreen: false,
        shape: const CircleBorder(),
        overlayShape: const CircleBorder(),
        showPulseAnimation: true,
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {
          if (area == TapArea.hole) {
            next();
          }
        },
      ),
      OnboardingStep(
        focusNode: app.focusNodes[2],
        titleText: 'tutorSWTitle04'.tr(),
        bodyText: 'tutorSWMsg04'.tr(),
        fullscreen: false,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
        overlayShape: const CircleBorder(),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[3],
        titleText: 'tutorSWTitle05'.tr(),
        bodyText: 'tutorSWMsg05'.tr(),
        fullscreen: false,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
        overlayShape: const CircleBorder(),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[4],
        titleText: 'tutorSWTitle06'.tr(),
        bodyText: 'tutorSWMsg06'.tr(),
        fullscreen: false,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
        overlayShape: const CircleBorder(),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[6],
        titleText: 'tutorSWTitle08'.tr(),
        bodyText: 'tutorSWMsg08'.tr(),
        fullscreen: false,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
        overlayShape: const CircleBorder(),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[5],
        titleText: 'tutorSWTitle07'.tr(),
        bodyText: 'tutorSWMsg07'.tr(),
        fullscreen: false,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
        overlayShape: const CircleBorder(),
        onTapCallback: (area, next, close) {
          Navigator.pop(context);
          next();
        },
      ),
      OnboardingStep(
        focusNode: FocusNode(),
        titleText: 'tutorSWTitle09'.tr(),
        bodyText: 'tutorSWMsg09'.tr(),
        fullscreen: false,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
        shape: const CircleBorder(),
        overlayShape: const CircleBorder(),
        showPulseAnimation: true,
      ),
      OnboardingStep(
        focusNode: FocusNode(),
        titleText: 'tutorSWTitle10'.tr(),
        bodyText: 'tutorSWMsg10'.tr(),
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
                color: Colors.blue.withOpacity(0.9),
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
                    ButtonBar(
                      children: [
                        FilledButton(
                          onPressed: renderInfo.nextStep,
                          child: const Text('Next'),
                        ),
                        FilledButton(
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
        focusNode: app.focusNodes[7],
        titleText: 'tutorSWTitle11'.tr(),
        bodyText: 'tutorSWMsg11'.tr(),
        fullscreen: false,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
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

      // Continue tutorial... (11)
      OnboardingStep(
        focusNode: app.focusNodes[11],
        titleText: 'tutorSWTitle12'.tr(),
        bodyText: 'tutorSWMsg12'.tr(),
        fullscreen: true,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[13],
        titleText: 'tutorSWTitle12'.tr(),
        bodyText: 'tutorSWMsg12'.tr(),
        fullscreen: true,
        // overlayShape: const CircleBorder(),
        overlayColor: Colors.blueAccent.withOpacity(0.9),
      ),
      OnboardingStep(
        focusNode: FocusNode(),
        titleText: 'tutorSWTitle13'.tr(),
        bodyText: 'tutorSWMsg13'.tr(),
        fullscreen: true,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
        onTapCallback: (area, next, close) => next(),
        stepBuilder: (context, renderInfo) => fullScreenMessage(
          context: context,
          render: renderInfo,
          image: 'assets/images/user_settings.png',
          scale: 2,
        ),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[12],
        titleText: 'tutorSWTitle14'.tr(),
        bodyText: 'tutorSWMsg14'.tr(),
        fullscreen: false,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
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
        focusNode: app.focusNodes[11],
        titleText: 'tutorSWTitle15'.tr(),
        bodyText: 'tutorSWMsg15'.tr(),
        fullscreen: true,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[14],
        titleText: 'tutorSWTitle16'.tr(),
        bodyText: 'tutorSWMsg16'.tr(),
        overlayColor: Colors.blueAccent.withOpacity(0.8),
        fullscreen: false,
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
        focusNode: app.focusNodes[17],
        titleText: 'tutorSWTitle17'.tr(),
        bodyText: 'tutorSWMsg17'.tr(),
        fullscreen: false,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
        overlayShape: const CircleBorder(),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[15],
        titleText: 'tutorSWTitle18'.tr(),
        bodyText: 'tutorSWMsg18'.tr(),
        fullscreen: false,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
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
        focusNode: app.focusNodes[11],
        titleText: 'tutorSWTitle18'.tr(),
        bodyText: 'tutorSWMsg18'.tr(),
        fullscreen: false,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
        overlayShape: const CircleBorder(),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[16],
        titleText: 'tutorSWTitle20'.tr(),
        bodyText: 'tutorSWMsg20'.tr(),
        fullscreen: false,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
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
        focusNode: FocusNode(),
        titleText: 'tutorSWTitle21'.tr(),
        bodyText: 'tutorSWMsg21'.tr(),
        fullscreen: true,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
        overlayShape: const CircleBorder(),
        showPulseAnimation: true,
        onTapCallback: (area, next, close) => next(),
        stepBuilder: (context, renderInfo) => fullScreenMessage(
          context: context,
          render: renderInfo,
          image: 'assets/images/dismissingLeft.png',
        ),
      ),
      OnboardingStep(
        focusNode: FocusNode(),
        titleText: 'tutorSWTitle22'.tr(),
        bodyText: 'tutorSWMsg22'.tr(),
        fullscreen: true,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
        overlayShape: const CircleBorder(),
        overlayBehavior: HitTestBehavior.translucent,
        showPulseAnimation: true,
        onTapCallback: (area, next, close) {
          close();
          app.tutorialOn = false;
        },
        stepBuilder: (context, renderInfo) => fullScreenMessage(
          context: context,
          render: renderInfo,
          image: 'assets/images/dismissingRight.png',
        ),
      ),
    ];
  }

  SizedBox fullScreenMessage({
    required BuildContext context,
    required OnboardingStepRenderInfo render,
    required String image,
    double? scale,
  }) {
    return SizedBox(
      width: render.size.width * 0.8,
      height: 400,
      child: Material(
        child: Container(
          color: Colors.blueAccent.withOpacity(0.9),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  render.titleText,
                  style: render.titleStyle,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Image.asset(
                    image,
                    scale: scale,
                  ),
                ),
                Text(
                  render.bodyText,
                  style: render.bodyStyle,
                ),
              ],
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
      child: const StopWatchPage(),
    );
  }
}
