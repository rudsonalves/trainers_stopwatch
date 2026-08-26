import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '/common/icons/stopwatch_icons_icons.dart';
import '/common/presentation/training_value_formatter.dart';
import '/domain/common/training/events/training_event.dart';
import '../../../components/dismissible_backgrounds.dart';

class DismissibleHistory extends StatelessWidget {
  final TrainingEvent event;
  final bool enableDelete;
  final Future<void> Function(TrainingEvent event) editHistory;
  final Future<bool> Function(int historyId) deleteHistory;
  final bool enabled;

  const DismissibleHistory({
    super.key,
    required this.event,
    required this.enableDelete,
    required this.editHistory,
    required this.deleteHistory,
    this.enabled = true,
  });

  String get label => switch (event) {
        TrainingStarted() => 'HPCTrainingStarting'.tr(),
        SplitRecorded(:final splitIndex) => 'Split[$splitIndex]',
        LapRecorded(:final lapIndex) => 'Lap[$lapIndex]',
      };

  Duration get duration => switch (event) {
        TrainingStarted() => Duration.zero,
        SplitRecorded(:final duration) => duration,
        LapRecorded(:final duration) => duration,
      };

  String get title =>
      '$label time: ${TrainingValueFormatter.formatDuration(duration)}';

  String get subtitle => switch (event) {
        LapRecorded(:final speed) =>
          'Speed: ${TrainingValueFormatter.formatSpeed(speed)}',
        _ => event.comments ?? '',
      };

  IconData get icon => switch (event) {
        TrainingStarted() => StopwatchIcons.start,
        SplitRecorded() => StopwatchIcons.partial,
        LapRecorded() => StopwatchIcons.lap,
      };

  @override
  Widget build(BuildContext context) => Dismissible(
        key: ValueKey('${event.runtimeType}-${event.historyId}'),
        direction:
            enabled ? DismissDirection.horizontal : DismissDirection.none,
        background: DismissibleContainers.background(context),
        secondaryBackground: DismissibleContainers.secondaryBackground(
          context,
          enable: enableDelete,
        ),
        confirmDismiss: (direction) async {
          final id = event.historyId;
          if (id == null) return false;
          if (direction == DismissDirection.startToEnd) {
            await editHistory(event);
          } else if (enableDelete) {
            return deleteHistory(id);
          }
          return false;
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: ListTile(
            title: Text(title),
            subtitle: Text(subtitle),
            leading: Icon(icon),
          ),
        ),
      );
}
