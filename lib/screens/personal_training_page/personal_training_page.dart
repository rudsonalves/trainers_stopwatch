import 'package:flutter/material.dart';

import '../../common/theme/app_font_style.dart';
import '../widgets/precise_stopwatch/precise_stopwatch.dart';
import '../widgets/precise_stopwatch/precise_stopwatch_controller.dart';
import 'widgets/dismissible_personal_training.dart';

class PersonalTrainingPage extends StatefulWidget {
  final PreciseStopwatch stopwatch;

  const PersonalTrainingPage({
    super.key,
    required this.stopwatch,
  });

  static const routeName = '/training';

  static Widget fromContext(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final stopwatch = args['stopwatch']! as PreciseStopwatch;

    return PersonalTrainingPage(
      stopwatch: stopwatch,
    );
  }

  @override
  State<PersonalTrainingPage> createState() => _PersonalTrainingPageState();
}

class _PersonalTrainingPageState extends State<PersonalTrainingPage> {
  late final PreciseStopwatchController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.stopwatch.controller;
  }

  @override
  Widget build(BuildContext context) {
    final training = _controller.training;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stopwatch.athlete.name),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PreciseStopwatch(
              athlete: widget.stopwatch.athlete,
              controller: widget.stopwatch.controller,
              isNotClone: false,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Split Distance: ${training.splitLength} ${training.speedUnit}',
                style: AppFontStyle.roboto16,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Lap Distance: ${training.lapLength} ${training.distanceUnit}',
                style: AppFontStyle.roboto16,
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: _controller.actionOnPress,
                builder: (context, _) {
                  final histories = _controller.histories.reversed.toList();

                  return ListView.builder(
                    itemCount: _controller.histories.length,
                    itemBuilder: (context, index) =>
                        DismissiblePersonalTraining(
                      history: histories[index],
                      training: _controller.training,
                      speedCalc: _controller.speedCalc,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
