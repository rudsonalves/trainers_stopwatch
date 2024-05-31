import 'package:flutter/material.dart';
import 'package:onboarding_overlay/onboarding_overlay.dart';
import 'package:trainers_stopwatch/common/singletons/app_settings.dart';
import 'package:trainers_stopwatch/screens/athletes_page/athletes_page.dart';

class AthletesOverlay extends StatefulWidget {
  const AthletesOverlay({super.key});

  static const routeName = '/athletes';

  @override
  State<AthletesOverlay> createState() => _AthletesOverlayState();
}

class _AthletesOverlayState extends State<AthletesOverlay> {
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
        titleText: 'Atheltas',
        bodyText: 'Nesta página você deve cadastrar os athletas para habilitar '
            'seu cronômetro de treino.',
        fullscreen: false,
        overlayShape: const CircleBorder(),
        overlayColor: Colors.green.withOpacity(0.9),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[8],
        titleText: 'Adicionar Atleta',
        bodyText:
            'Para adicionar novos atletas pressione este botão flutuante.',
        fullscreen: false,
        shape: const CircleBorder(),
        overlayShape: const CircleBorder(),
        overlayColor: Colors.green.withOpacity(0.9),
        showPulseAnimation: true,
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {
          if (area == TapArea.hole) {
            close();
          }
        },
      ),
      OnboardingStep(
        focusNode: app.focusNodes[8],
        titleText: 'Adicionar Atleta',
        bodyText:
            'Para adicionar novos atletas pressione este botão flutuante.',
        fullscreen: false,
        shape: const CircleBorder(),
        overlayShape: const CircleBorder(),
        overlayColor: Colors.green.withOpacity(0.9),
        showPulseAnimation: true,
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {
          if (area == TapArea.hole) {
            next();
          }
        },
      ),
      OnboardingStep(
        focusNode: FocusNode(),
        titleText: 'Adicione um usuário',
        bodyText: 'Adicione um usuário para continuar!',
        overlayShape: const CircleBorder(),
        overlayColor: Colors.green.withOpacity(0.9),
        fullscreen: false,
        onTapCallback: (area, next, close) => close(),
      ),
      // Continue...
      OnboardingStep(
        focusNode: app.focusNodes[9],
        titleText: 'Seleção para Treino',
        bodyText: 'Selecione um atleta ou mais para iniciar o treino, clicando '
            'sobre seu cadastro.',
        fullscreen: true,
        overlayColor: Colors.green.withOpacity(0.9),
        overlayShape: const CircleBorder(),
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {
          if (area == TapArea.hole) {
            next();
          }
        },
      ),
      OnboardingStep(
        focusNode: app.focusNodes[9],
        titleText: 'Selecionados',
        bodyText:
            'Atletas selecionados irão criar cronômetros na página inicial '
            'do aplicativo.',
        fullscreen: false,
        overlayShape: const CircleBorder(),
        overlayColor: Colors.green.withOpacity(0.9),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[10],
        titleText: 'Abrir Cronômetros',
        bodyText:
            'Uma vez selecionados os atletas para treino, pressione o botão '
            'de volta para a página incial.',
        fullscreen: false,
        overlayColor: Colors.green.withOpacity(0.9),
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
      child: const AthletesPage(),
    );
  }
}
