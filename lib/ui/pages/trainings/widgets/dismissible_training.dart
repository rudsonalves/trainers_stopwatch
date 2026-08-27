import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '/domain/common/training/models/training.dart';
import '../../../components/dismissibles/dismissible_backgrounds.dart';

class DismissibleTraining extends StatelessWidget {
  final Training training;
  final Future<void> Function(Training training) openHistory;
  final Future<bool> Function(Training training) removeTraining;
  final ValueChanged<Training> onSelect;
  final bool selected;
  final bool enabled;

  const DismissibleTraining({
    super.key,
    required this.training,
    required this.openHistory,
    required this.removeTraining,
    required this.onSelect,
    required this.selected,
    this.enabled = true,
  });

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
          color: selected
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
            onTap: enabled ? () => onSelect(training) : null,
          ),
        ),
      ),
    );
  }
}
