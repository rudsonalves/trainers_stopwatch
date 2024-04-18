import 'package:flutter/material.dart';

import '../../../common/icons/stopwatch_icons_icons.dart';
import '../../../models/history_model.dart';

class CardHistory extends StatefulWidget {
  final String startMessage;
  final HistoryModel history;

  const CardHistory({
    super.key,
    required this.history,
    required this.startMessage,
  });

  @override
  State<CardHistory> createState() => _CardHistoryState();
}

class _CardHistoryState extends State<CardHistory> {
  String get title {
    if (widget.history.duration == const Duration()) {
      return 'Training Starting';
    }

    String time = widget.history.duration.toString();
    while (time[0] == '0' || time[0] == ':') {
      time = time.substring(1);
    }
    time = time.substring(0, time.length - 4);

    if (widget.history.lap != null) {
      return 'Lap[${widget.history.lap}] time: ${time}s';
    }

    return 'Split[${widget.history.split}] time: ${time}s';
  }

  IconData get iconData {
    if (widget.history.duration == const Duration()) {
      return StopwatchIcons.start;
    } else if (widget.history.lap != null) {
      return StopwatchIcons.lap;
    }
    return StopwatchIcons.partial;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(widget.history.comments ?? widget.startMessage),
        leading: Icon(iconData),
      ),
    );
  }
}
