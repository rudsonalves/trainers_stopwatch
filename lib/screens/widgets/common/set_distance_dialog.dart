import 'package:flutter/material.dart';

import '../../../models/training_model.dart';
import 'numeric_field.dart';

class SetDistancesDialog extends StatefulWidget {
  final TrainingModel training;

  const SetDistancesDialog({
    super.key,
    required this.training,
  });

  static Future<bool> open(BuildContext context, TrainingModel training) async {
    final bool result = await showDialog<bool?>(
          context: context,
          builder: (context) => SetDistancesDialog(
            training: training,
          ),
        ) ??
        false;

    return result;
  }

  @override
  State<SetDistancesDialog> createState() => _SetDistancesDialogState();
}

class _SetDistancesDialogState extends State<SetDistancesDialog> {
  final splitController = TextEditingController(text: '');
  final lapController = TextEditingController(text: '');
  final splitFocusnode = FocusNode();
  final lapFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FocusScope.of(context).requestFocus(splitFocusnode);
    });
  }

  @override
  void dispose() {
    splitController.dispose();
    lapController.dispose();
    super.dispose();
  }

  void _applyButton() {
    final split = splitController.text;
    final lap = lapController.text;
    widget.training.splitLength =
        split != '0' && split.isNotEmpty ? double.parse(split) : null;
    widget.training.lapLength =
        lap.isNotEmpty && lap != '0' ? double.parse(lap) : null;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Training Distances'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        NumericField(
          focusNode: splitFocusnode,
          label: 'Split Distance (m)',
          controller: splitController,
          value: widget.training.splitLength,
          onSubmitted: (_) => FocusScope.of(context).requestFocus(lapFocusNode),
        ),
        NumericField(
          focusNode: lapFocusNode,
          label: 'Lap Distance (m)',
          controller: lapController,
          value: widget.training.lapLength,
        ),
        const SizedBox(height: 12),
        ButtonBar(
          children: [
            ElevatedButton(
              onPressed: _applyButton,
              child: const Text('Apply'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ],
    );
  }
}
