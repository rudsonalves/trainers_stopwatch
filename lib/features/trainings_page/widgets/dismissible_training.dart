// Copyright (C) 2024 Rudson Alves
// 
// This file is part of trainers_stopwatch.
// 
// trainers_stopwatch is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// trainers_stopwatch is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with trainers_stopwatch.  If not, see <https://www.gnu.org/licenses/>.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../common/models/training_model.dart';
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
      subtitle = 'DTSubtitle'.tr(args: [
        training.lapLength.toStringAsFixed(1),
        training.distanceUnit,
        training.splitLength.toStringAsFixed(1),
        training.distanceUnit,
      ]);
    }

    return (title, subtitle);
  }

  void _onTap() {
    onTapSelect!(training.id!);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    String title;
    String subtitle;

    (title, subtitle) = _mountListTile(training);

    return Dismissible(
      background: DismissibleContainers.background(context),
      secondaryBackground: DismissibleContainers.secondaryBackground(context),
      key: GlobalKey(),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.secondaryContainer,
          ),
          color: selected
              ? colorScheme.tertiaryContainer.withOpacity(0.5)
              : colorScheme.surfaceBright,
          borderRadius: BorderRadius.circular(20),
        ),
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
