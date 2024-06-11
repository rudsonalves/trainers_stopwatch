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
    final baseColor = Colors.cyan.withOpacity(0.9);

    steps = [
      OnboardingStep(
        focusNode: FocusNode(),
        titleText: 'Training Page',
        bodyText:
            'Este tutoria funcinará apenas se você tiver alguns treinamentos '
            'armaenados no aplicativo. Caso não tenha crie alguns na página principal e '
            'retome aqui para seguir o tutorial.',
        fullscreen: false,
        overlayShape: const CircleBorder(),
        overlayColor: baseColor,
      ),
      OnboardingStep(
        focusNode: app.focusNodes[23],
        titleText: 'Select User',
        bodyText: 'Primeiro selecione um usuário com treinos registrados.',
        overlayColor: baseColor,
        overlayShape: const CircleBorder(),
        overlayBehavior: HitTestBehavior.translucent,
        showPulseAnimation: true,
      ),
      OnboardingStep(
        focusNode: app.focusNodes[24],
        titleText: 'Select User',
        bodyText: 'Primeiro selecione um usuário com treinos registrados.',
        overlayColor: baseColor,
        overlayShape: const CircleBorder(),
        overlayBehavior: HitTestBehavior.translucent,
        showPulseAnimation: true,
      ),
    ];
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
