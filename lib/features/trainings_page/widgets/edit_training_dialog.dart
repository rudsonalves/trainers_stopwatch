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

class EditTrainingDialog extends StatefulWidget {
  final TrainingModel training;

  const EditTrainingDialog({
    super.key,
    required this.training,
  });

  static Future<bool> open(BuildContext context, TrainingModel training) async {
    final result = await showDialog<bool>(
          context: context,
          builder: (context) => EditTrainingDialog(training: training),
        ) ??
        false;

    return result;
  }

  @override
  State<EditTrainingDialog> createState() => _EditTrainingDialogState();
}

class _EditTrainingDialogState extends State<EditTrainingDialog> {
  final commantsController = TextEditingController();
  late TrainingModel training;

  @override
  void initState() {
    super.initState();
    training = widget.training;
    commantsController.text = training.comments ?? '';
  }

  @override
  void dispose() {
    commantsController.dispose();
    super.dispose();
  }

  void _applyChanges() {
    training.comments = commantsController.text;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final date = training.date;
    String trainingDate = '${DateFormat.yMMMEd().format(date)} - '
        '${DateFormat.Hm().format(date)}';

    return AlertDialog(
      title: Text('ETD2Title'.tr()),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(trainingDate),
          Text('Lap: ${training.lapLength} ${training.distanceUnit}'),
          Text('Split: ${training.splitLength} ${training.distanceUnit}'),
          TextField(
            controller: commantsController,
            decoration: InputDecoration(
              label: Text('ETDComments'.tr()),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
      actions: [
        FilledButton.tonal(
          onPressed: _applyChanges,
          child: Text('GenericApply'.tr()),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.pop(context),
          child: Text('GenericCancel'.tr()),
        ),
      ],
    );
  }
}
