import 'package:flutter/material.dart';

import '../../../common/icons/stopwatch_icons_icons.dart';
import '../../../models/history_model.dart';
import '../../../models/training_model.dart';

class DismissiblePersonalTraining extends StatelessWidget {
  final HistoryModel history;
  final TrainingModel training;
  final String Function(double length, double time) speedCalc;

  const DismissiblePersonalTraining({
    super.key,
    required this.history,
    required this.training,
    required this.speedCalc,
  });

  (String, String, bool) _generateTitles() {
    String title = formatTime(history.duration);
    double length;
    double time = history.duration.inMilliseconds / 1000;
    if (history.lap != null) {
      title = 'Lap [${history.lap}] time: $title';
      length = training.lapLength;
    } else {
      title = 'Split [${history.split}] time: $title';
      length = training.splitLength;
    }

    String speed = speedCalc(length, time);
    String subtitle = 'Speed: $speed';

    return (title, subtitle, history.lap != null);
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
    String title;
    String subtitle;
    bool isLap;

    (title, subtitle, isLap) = _generateTitles();

    return Dismissible(
      key: GlobalKey(),
      child: Card(
        child: ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          leading: Icon(
            isLap ? StopwatchIcons.lap : StopwatchIcons.partial,
          ),
        ),
      ),
      confirmDismiss: (direction) async => false,
    );
  }
}
