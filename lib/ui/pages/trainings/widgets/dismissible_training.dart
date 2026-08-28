import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '/domain/common/training/models/training.dart';
import '/ui/components/dismissibles/dismissible_backgrounds.dart';
import '../viewmodel/models/training_selection_state.dart';

class DismissibleTraining extends StatelessWidget {
  final Training training;
  final Future<void> Function(Training training) openHistory;
  final Future<bool> Function(Training training) removeTraining;
  final ValueChanged<Training> onSelect;
  final TrainingSelectionState selectionState;
  final bool enabled;
  final ValueChanged<Training>? onRejectedTap;

  const DismissibleTraining({
    super.key,
    required this.training,
    required this.openHistory,
    required this.removeTraining,
    required this.onSelect,
    required this.selectionState,
    this.enabled = true,
    this.onRejectedTap,
  });

  bool get _isSelected => selectionState == TrainingSelectionState.selected;

  IconData get _selectionIcon => switch (selectionState) {
        TrainingSelectionState.unselected => Icons.radio_button_unchecked,
        TrainingSelectionState.selected => Icons.check_circle,
        TrainingSelectionState.rejected => Icons.error,
      };

  String get _selectionLabel => switch (selectionState) {
        TrainingSelectionState.unselected => 'TPTrainingStateUnselected'.tr(),
        TrainingSelectionState.selected => 'TPTrainingStateSelected'.tr(),
        TrainingSelectionState.rejected => 'TPTrainingStateRejected'.tr(),
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (title, subtitle) = _labels();
    return Dismissible(
      key: ValueKey(training.id),
      background: DismissibleContainers.background(context),
      direction: enabled ? DismissDirection.horizontal : DismissDirection.none,
      secondaryBackground: DismissibleContainers.secondaryBackground(context),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await openHistory(training);
        } else {
          await removeTraining(training);
        }
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: _isSelected
              ? colorScheme.tertiaryContainer.withValues(alpha: 0.5)
              : colorScheme.surfaceBright,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: colorScheme.secondaryContainer),
          ),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            title: Text(title),
            subtitle: Text(subtitle),
            onTap: !enabled
                ? null
                : selectionState == TrainingSelectionState.rejected
                    ? onRejectedTap == null
                        ? null
                        : () => onRejectedTap!(training)
                    : () => onSelect(training),
            trailing: _buildSelectionIndicator(colorScheme),
          ),
        ),
      ),
    );
  }

  (String, String) _labels() {
    final date = training.date;
    final title = '${DateFormat.yMMMEd().format(date)} - '
        '${DateFormat.Hm().format(date)}';
    final comments = training.comments ?? '';
    final subtitle = comments.isNotEmpty
        ? comments
        : 'DTSubtitle'.tr(args: [
            training.lapDistance.value.toStringAsFixed(1),
            training.lapDistance.unit.symbol,
            training.splitDistance.value.toStringAsFixed(1),
            training.splitDistance.unit.symbol,
          ]);
    return (title, subtitle);
  }

  Widget _buildSelectionIndicator(ColorScheme colorScheme) {
    final color = switch (selectionState) {
      TrainingSelectionState.unselected => colorScheme.outline,
      TrainingSelectionState.selected => colorScheme.primary,
      TrainingSelectionState.rejected => colorScheme.error,
    };

    final icon = Icon(
      _selectionIcon,
      color: color,
      semanticLabel: _selectionLabel,
    );

    if (selectionState != TrainingSelectionState.rejected) {
      return Tooltip(
        message: _selectionLabel,
        child: icon,
      );
    }

    return IconButton(
      tooltip: _selectionLabel,
      color: color,
      disabledColor: color,
      onPressed: enabled && onRejectedTap != null
          ? () => onRejectedTap!(training)
          : null,
      icon: icon,
    );
  }
}
