import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../common/icons/stopwatch_icons_icons.dart';
import '../../../common/models/history_model.dart';
import 'dismissible_backgrounds.dart';
import 'edit_history_dialog.dart';

class DismissibleHistory extends StatefulWidget {
  final HistoryModel history;
  final Future<void> Function(HistoryModel) managerUpdade;
  final Future<void> Function(HistoryModel) managerDelete;

  const DismissibleHistory({
    super.key,
    required this.history,
    required this.managerUpdade,
    required this.managerDelete,
  });

  @override
  State<DismissibleHistory> createState() => _DismissibleHistoryState();
}

class _DismissibleHistoryState extends State<DismissibleHistory> {
  Future<bool> _editHistory() async {
    final result = await EditHistoryDialog.open(
      context,
      title: 'title',
      history: widget.history,
    );

    if (result) {
      widget.managerUpdade(widget.history);
    }

    return true;
  }

  Future<bool> _deleteHistory() async {
    return false;
  }

  String get title {
    if (widget.history.duration == const Duration()) {
      return 'HPCTrainingStarting'.tr();
    }

    String time = widget.history.duration.toString();
    while (time[0] == '0' || time[0] == ':') {
      time = time.substring(1);
    }
    time = time.substring(0, time.length - 4);

    if (widget.history.lap != null) {
      return 'HPCLapTime'.tr(args: [
        widget.history.lap.toString(),
        time,
      ]);
    }

    return 'HPCSplitTime'.tr(args: [
      widget.history.split.toString(),
      time,
    ]);
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
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: GlobalKey(),
      background: DismissibleContainers.background(context),
      secondaryBackground: DismissibleContainers.secondaryBackground(context),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
        ),
        child: ListTile(
          title: Text(title),
          subtitle: Text(widget.history.comments ?? ''),
          leading: Icon(iconData),
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await _editHistory();
        } else if (direction == DismissDirection.endToStart) {
          return await _deleteHistory();
        }
        return false;
      },
    );
  }
}
