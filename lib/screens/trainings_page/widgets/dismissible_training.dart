import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/training_model.dart';
import '../../widgets/common/dismissible_backgrounds.dart';

class DismissibleTraining extends StatelessWidget {
  final TrainingModel training;
  final Future<void> Function(TrainingModel training) editTraining;
  final Future<bool> Function(TrainingModel training) removeTraining;
  final void Function(int id)? onTapSelect;
  final bool selected;

  const DismissibleTraining({
    super.key,
    required this.training,
    required this.editTraining,
    required this.removeTraining,
    this.onTapSelect,
    required this.selected,
  });

  (String title, String subtitle) _mountListTile(TrainingModel training) {
    final date = training.date;
    String title = '${DateFormat.yMMMEd().format(date)} - '
        '${DateFormat.Hm().format(date)}';
    String subtitle = training.comments ?? '';
    if (subtitle.isEmpty) {
      subtitle =
          'Distances: Lap ${training.lapLength} ${training.distanceUnit}  '
          'Split ${training.splitLength} ${training.distanceUnit}';
    }

    return (title, subtitle);
  }

  void _onTap() {
    onTapSelect!(training.id!);
  }

  @override
  Widget build(BuildContext context) {
    String title;
    String subtitle;

    (title, subtitle) = _mountListTile(training);

    return Dismissible(
      background: DismissibleContainers.background(context),
      secondaryBackground: DismissibleContainers.secondaryBackground(context),
      key: GlobalKey(),
      child: Card(
        elevation: selected ? 5 : 0,
        child: ListTile(
          title: Text(
            title,
          ),
          subtitle: Text(subtitle),
          onTap: _onTap,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await editTraining(training);
        } else if (direction == DismissDirection.endToStart) {
          await removeTraining(training);
        }
        return false;
      },
    );
  }
}
