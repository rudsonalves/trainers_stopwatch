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
        titleText: 'Trainer\'s Stopwatch Tutorial',
        bodyText:
            'Este tutorial vai lhe apresentar os passo básicos para melhor '
            'usar o Trainer\'s Stopwatch. Caso deseje repetir o tutorial acesso no ícone'
            ' "?", no menu do aplicativo.',
        fullscreen: false,
        overlayColor: Colors.blue.withOpacity(0.9),
        shape: const CircleBorder(),
        overlayShape: const CircleBorder(),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[0],
        titleText: 'Tocar Tema',
        bodyText: 'Este botão permite permutar entre os temas claro/escuro.',
        fullscreen: false,
        overlayColor: Colors.blue.withOpacity(0.9),
        shape: const CircleBorder(),
        overlayShape: const CircleBorder(),
        showPulseAnimation: true,
        overlayBehavior: HitTestBehavior.deferToChild,
      ),
      OnboardingStep(
        focusNode: app.focusNodes[1],
        titleText: 'Menu',
        bodyText:
            'Permite acessar outras páginas do aplicativo, configurações e '
            'informações. Abra o menu para prosseguir',
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
        titleText: 'Gerenciar Usuários',
        bodyText:
            'Esta página permite cadastrar, editar e remover usuários, além '
            'de abrir os cornômetros para os usuários selecionados.',
        fullscreen: false,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
        overlayShape: const CircleBorder(),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[3],
        titleText: 'Gerenciar Treinamentos',
        bodyText:
            'Esta página permite editar, apagar e remover treinamentos gravados.',
        fullscreen: false,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
        overlayShape: const CircleBorder(),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[4],
        titleText: 'Configuraçãoes',
        bodyText:
            'Esta página permite editar, apagar e remover treinamentos gravados.',
        fullscreen: false,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
        overlayShape: const CircleBorder(),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[5],
        titleText: 'Tutorial',
        bodyText: 'Iniciar o tutotial.',
        fullscreen: false,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
        overlayShape: const CircleBorder(),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[6],
        titleText: 'Sobre',
        bodyText: 'Apresenta a página de informações do aplicativo.',
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
        titleText: 'Adicionar Usuários',
        bodyText:
            'Para iniciar o uso do aplicativo você necessita adicionar alguns '
            'usuários para treino. Isto pode ser feito pressionando botão flutuante '
            'ou no Menu > Gerenciar Usuários, ou pressionar o botão abaixo.',
        fullscreen: false,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
        shape: const CircleBorder(),
        overlayShape: const CircleBorder(),
        showPulseAnimation: true,
      ),
      OnboardingStep(
        focusNode: FocusNode(),
        titleText: 'Interromper Tutorial',
        bodyText:
            'O tutorial prosseguirá pela página de adição de usuários. Você '
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
        titleText: 'Adicionar Usuários',
        bodyText:
            'Antes de iniciar o uso do seu cronômetro é necessário cadastrar '
            'os usuários que farão o treino. Pressione aqui.',
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
        titleText: 'Stopwatch',
        bodyText:
            'Neste momento um novo cronômetro para o treinamento é criado, e '
            'o seu treino pode ser gerenciado pelo aplicativo.',
        fullscreen: true,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[13],
        titleText: 'Configurações',
        bodyText: 'Este botão abre a configuração para o treino, onde se pode '
            'ajustar unidades, comprimentos das voltas e dos splits e total de voltas.',
        fullscreen: false,
        overlayShape: const CircleBorder(),
        overlayColor: Colors.blueAccent.withOpacity(0.9),
      ),
      OnboardingStep(
        focusNode: FocusNode(),
        titleText: 'Configurações',
        bodyText:
            'As configurações podem ser ajustadas antes de iniciar o treino.',
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
        titleText: 'Iniciar',
        bodyText:
            'Este botão inicia o treino, disparando o cronômetro. Pressione-o '
            'para prosseguir',
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
        titleText: 'Cronômetro',
        bodyText:
            'Uma vez o cornômetro iniciado, os instantes são marcados na lista '
            'de logs abaixo.',
        fullscreen: true,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[14],
        titleText: 'Split/Lap',
        bodyText: 'Os botões do cronômetro são apresentados por demanda, '
            'mostrando apenas os botões ativos. O botão Split/Lap permite '
            'registra uma split/Lap quando pressionado.',
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
        titleText: 'Registros',
        bodyText: 'Os registros são adicionados no quadro abaixo, a cada ação.',
        fullscreen: false,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
        overlayShape: const CircleBorder(),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[15],
        titleText: 'Parar',
        bodyText:
            'O botão Pause irá parar o treinamento, possibilitando continuar, '
            'reiniciar e terminar o treinamento.',
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
        titleText: 'Cont./Reset/Finish',
        bodyText:
            'Os botões reiniciar e terminar são acionados por uma pressão longa, '
            'por isto possuem uma coloração levemente diferente nos ícones.',
        fullscreen: false,
        overlayColor: Colors.blueAccent.withOpacity(0.9),
        overlayShape: const CircleBorder(),
      ),
      OnboardingStep(
        focusNode: app.focusNodes[16],
        titleText: 'Fininsh',
        bodyText:
            'Para terminar o treinamento faça uma pressão longa no botão Finish.'
            'reiniciar e terminar o treinamento.',
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
        titleText: 'Gerenciar um Treino',
        bodyText: 'Você pode gerenciar o treino de um usuário, com total foco, '
            'deslizando-o para direita.',
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
        titleText: 'Remover Treino',
        bodyText: 'Voce pode remover um treino deslizando-o para esquerda. '
            'Treinos removidos não são apagados, ficam disponíveis para consulta e '
            'edição no Menu -> Gestão de treinamento ',
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
