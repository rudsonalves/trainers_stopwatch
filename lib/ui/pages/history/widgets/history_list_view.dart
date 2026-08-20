import 'package:flutter/material.dart';

import '/domain/common/history/models/history_entry.dart';
import '/domain/common/training/events/training_event.dart';
import 'dismissible_history.dart';
import 'edit_history_dialog.dart';

class HistoryListView extends StatelessWidget {
  final List<TrainingEvent> events;
  final List<HistoryEntry> histories;
  final Future<void> Function({
    required int historyEntryId,
    String? comments,
  }) updateComments;
  final Future<bool> Function(int historyId) deleteHistory;
  final bool reversed;

  const HistoryListView({
    super.key,
    required this.events,
    required this.histories,
    required this.updateComments,
    required this.deleteHistory,
    this.reversed = false,
  });

  Future<void> _edit(BuildContext context, TrainingEvent event) async {
    final id = event.historyId;
    if (id == null) return;
    final comments = await EditHistoryDialog.open(
      context,
      title: _title(event),
      comments:
          histories.where((history) => history.id == id).firstOrNull?.comments,
    );
    if (comments == null) return;
    await updateComments(historyEntryId: id, comments: comments);
  }

  String _title(TrainingEvent event) => switch (event) {
        TrainingStarted() => 'Training',
        SplitRecorded(:final splitIndex) => 'Split[$splitIndex]',
        LapRecorded(:final lapIndex) => 'Lap[$lapIndex]',
      };

  bool _canDelete(TrainingEvent event) {
    if (event is! SplitRecorded) return false;
    final index = histories.indexWhere((entry) => entry.id == event.historyId);
    return index > 0 && index < histories.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final shownEvents = reversed ? events.reversed.toList() : events;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: ListView.builder(
        itemCount: shownEvents.length,
        itemBuilder: (context, index) {
          final event = shownEvents[index];
          return DismissibleHistory(
            event: event,
            enableDelete: _canDelete(event),
            editHistory: (event) => _edit(context, event),
            deleteHistory: deleteHistory,
          );
        },
      ),
    );
  }
}
