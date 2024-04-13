import 'package:flutter/material.dart';
import 'package:trainers_stopwatch/common/theme/app_font_style.dart';

import '../../common/icons/stopwatch_icons_icons.dart';
import '../widgets/precise_stopwatch/precise_stopwatch.dart';
import '../widgets/precise_stopwatch/precise_stopwatch_controller.dart';

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

  String formatTime(Duration duration) {
    String time = duration.toString();
    while (time[0] == '0' || time[0] == ':') {
      time = time.substring(1);
    }
    if (time[0] == '.') time = '0$time';

    return time.substring(0, time.length - 3);
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
                  return ListView.builder(
                    itemCount: _controller.histories.length,
                    itemBuilder: (context, index) {
                      final rindex = _controller.histories.length - 1 - index;
                      final history = _controller.histories[rindex];
                      final training = _controller.training;

                      String title = history.lap != null
                          ? 'Lap [${history.lap}] time: '
                          : 'Split time: ';
                      title += formatTime(history.duration);

                      String speed = _controller.speedCalc(
                        duration: history.duration,
                        distante: history.lap != null
                            ? training.splitLength
                            : training.lapLength,
                        distanceUnit: training.distanceUnit,
                        speedUnit: training.speedUnit,
                      );
                      String subtitle = 'Speed: $speed';

                      return Dismissible(
                        key: GlobalKey(),
                        child: Card(
                          child: ListTile(
                            title: Text(title),
                            subtitle: Text(subtitle),
                            leading: Icon(
                              history.lap != null
                                  ? StopwatchIcons.lap
                                  : StopwatchIcons.partial,
                            ),
                          ),
                        ),
                      );
                    },
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
