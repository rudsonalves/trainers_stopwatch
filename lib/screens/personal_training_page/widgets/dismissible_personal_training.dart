import 'package:flutter/material.dart';

import '../../../common/icons/stopwatch_icons_icons.dart';
import '../../../models/history_model.dart';
import '../../../models/training_model.dart';
import '../../widgets/common/dismissible_backgrounds.dart';
import 'edit_history_dialog/edit_history_dialog.dart';

class DismissiblePersonalTraining extends StatefulWidget {
  final HistoryModel history;
  final TrainingModel training;
  final String Function(double length, double time) speedCalc;

  const DismissiblePersonalTraining({
    super.key,
    required this.history,
    required this.training,
    required this.speedCalc,
  });

  @override
  State<DismissiblePersonalTraining> createState() =>
      _DismissiblePersonalTrainingState();
}

class _DismissiblePersonalTrainingState
    extends State<DismissiblePersonalTraining> {
  late String title;

  (String, String, bool) _generateTitles() {
    String title = formatTime(widget.history.duration);
    double length;
    double time = widget.history.duration.inMilliseconds / 1000;
    if (widget.history.lap != null) {
      title = 'Lap [${widget.history.lap}] time: $title';
      length = widget.training.lapLength;
    } else {
      title = 'Split [${widget.history.split}] time: $title';
      length = widget.training.splitLength;
    }

    String subtitle = widget.history.comments ?? '';
    if (subtitle.isEmpty) {
      final speed = widget.speedCalc(length, time);
      subtitle = 'Speed: $speed';
    }

    this.title = title;

    return (title, subtitle, widget.history.lap != null);
  }

  String formatTime(Duration duration) {
    String time = duration.toString();
    while (time[0] == '0' || time[0] == ':') {
      time = time.substring(1);
    }
    if (time[0] == '.') time = '0$time';

    return time.substring(0, time.length - 3);
  }

  Future<void> _editHistoty(BuildContext context) async {
    await EditHistoryDialog.open(
      context,
      title: title,
      history: widget.history,
    );
  }

  @override
  Widget build(BuildContext context) {
    String title;
    String subtitle;
    bool isLap;

    (title, subtitle, isLap) = _generateTitles();

    return Dismissible(
      background: DismissibleContainers.background(
        context,
      ),
      secondaryBackground: DismissibleContainers.secondaryBackground(
        context,
        enable: false,
      ),
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
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await _editHistoty(context);
          return false;
        } else if (direction == DismissDirection.endToStart) {
          return false;
        }
        return false;
      },
    );
  }
}
