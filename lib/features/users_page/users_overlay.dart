import 'package:flutter/material.dart';
import 'package:onboarding_overlay/onboarding_overlay.dart';
import 'package:trainers_stopwatch/common/singletons/app_settings.dart';
import 'package:trainers_stopwatch/features/users_page/users_page.dart';

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
    steps = [
      OnboardingStep(
        focusNode: FocusNode(),
        titleText: 'Atheltas',
        bodyText: 'Nesta página você deve cadastrar os usuários para habilitar '
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
        showPulseAnimation: true,
        onTapCallback: (area, next, close) {
          if (area == TapArea.hole) {
            next();
          }
        },
      ),
      OnboardingStep(
        focusNode: FocusNode(),
        titleText: 'Interromper Tutorial',
        bodyText: 'O tutorial prosseguirá pela página Users Management. Você '
            'pode interromper aqui ou prosseguir pala próxima parte do tutorial.',
        fullscreen: true,
        overlayBehavior: HitTestBehavior.translucent,
        onTapCallback: (area, next, close) {},
        stepBuilder: (context, renderInfo) => SizedBox(
          child: Material(
            child: Container(
              width: renderInfo.size.width * 0.9,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.green.withOpacity(0.9),
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
        focusNode: app.focusNodes[9],
        titleText: 'Selecionados',
        bodyText:
            'Atletas selecionados irão criar novos cronômetros na página inicial '
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
      child: const UsersPage(),
    );
  }
}
