import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/training_model.dart';

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
      title: const Text('Edit Training'),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(trainingDate),
          Text('Lap: ${training.lapLength} ${training.distanceUnit}'),
          Text('Split: ${training.splitLength} ${training.distanceUnit}'),
          TextField(
            controller: commantsController,
            decoration: const InputDecoration(
              label: Text('Comments'),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: _applyChanges,
          child: const Text('Apply'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
