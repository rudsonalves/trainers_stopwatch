import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signals/signals_flutter.dart';

import '../../../common/theme/app_font_style.dart';
import '../../../models/training_model.dart';
import '../common/numeric_field.dart';
import 'widgets/distance_unit_row.dart';
import 'widgets/speed_unit_row.dart';

class EditTrainingDialog extends StatefulWidget {
  final String athleteName;
  final TrainingModel training;

  const EditTrainingDialog({
    super.key,
    required this.athleteName,
    required this.training,
  });

  static Future<bool> open(
    BuildContext context, {
    required String athleteName,
    required TrainingModel training,
  }) async {
    final bool result = await showDialog<bool?>(
          context: context,
          builder: (context) => EditTrainingDialog(
            athleteName: athleteName,
            training: training,
          ),
        ) ??
        false;

    return result;
  }

  @override
  State<EditTrainingDialog> createState() => _EditTrainingDialogState();
}

class _EditTrainingDialogState extends State<EditTrainingDialog> {
  final splitController = TextEditingController(text: '');
  final lapController = TextEditingController(text: '');
  final commentsController = TextEditingController(text: '');
  final splitFocusNode = FocusNode();
  final lapFocusNode = FocusNode();
  final commentsFocusNode = FocusNode();
  final selectedDistUnit = signal<String>('m');
  List<String> distanceUnits = ['m', 'km', 'yd', 'mi'];
  final selectedSpeedUnit = signal<String>('m/s');
  List<String> speedUnits = ['m/s', 'km/h', 'yd/s', 'mph'];
  final speedAllowedValues = {
    'm': ['m/s', 'km/h'],
    'km': ['m/s', 'km/h'],
    'yd': ['yd/s', 'm/s', 'mph'],
    'mi': ['yd/s', 'm/s', 'mph'],
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FocusScope.of(context).requestFocus(splitFocusNode);
      final splitLength = widget.training.splitLength.toString();
      final lapLength = widget.training.lapLength.toString();
      splitController.text = splitLength;
      splitController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: splitLength.length,
      );
      lapController.text = lapLength;
      selectedDistUnit.value = widget.training.distanceUnit;
      selectedSpeedUnit.value = widget.training.speedUnit;
      commentsController.text = widget.training.comments ?? '';
    });
  }

  @override
  void dispose() {
    splitController.dispose();
    lapController.dispose();
    commentsController.dispose();
    selectedSpeedUnit.dispose();
    selectedDistUnit.dispose();
    splitFocusNode.dispose();
    lapFocusNode.dispose();
    commentsFocusNode.dispose();
    super.dispose();
  }

  void _applyButton() {
    final split = splitController.text;
    final lap = lapController.text;
    widget.training.splitLength =
        split != '0' && split.isNotEmpty ? double.parse(split) : 200;
    widget.training.lapLength =
        lap.isNotEmpty && lap != '0' ? double.parse(lap) : 1000;
    widget.training.distanceUnit = selectedDistUnit();
    widget.training.speedUnit = selectedSpeedUnit();
    widget.training.comments = commentsController.text;
    Navigator.pop(context, true);
  }

  void _onsubmittedSplit(String value) {
    FocusScope.of(context).requestFocus(lapFocusNode);
    lapController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: lapController.text.length,
    );
  }

  void _onsubmittedLap(String value) {
    FocusScope.of(context).requestFocus(commentsFocusNode);
    commentsController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: commentsController.text.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Center(child: Text('Training Settings')),
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      children: [
        const Divider(),
        Center(
          child: Text(
            widget.athleteName,
            style: AppFontStyle.roboto18SemiBold,
          ),
        ),
        Center(
          child: Text(
            '${DateFormat.yMMMMd().format(widget.training.date)} - '
            '${DateFormat.Hms().format(widget.training.date)}',
            style: AppFontStyle.roboto16,
          ),
        ),
        const Divider(),
        DistanceUnitRow(
          label: 'Distance Unit:',
          selectedUnit: selectedDistUnit,
          distanceUnits: distanceUnits,
          speedAllowedValues: speedAllowedValues,
          selectedSpeedUnit: selectedSpeedUnit,
        ),
        SpeedUnitRow(
          label: 'Speed Unit:',
          selectedSpeedUnit: selectedSpeedUnit,
          speedUnits: speedUnits,
          speedAllowedValues: speedAllowedValues,
          selectedDistUnit: selectedDistUnit,
        ),
        NumericField(
          focusNode: splitFocusNode,
          label: 'Split Distance (${selectedDistUnit.watch(context)})',
          controller: splitController,
          value: widget.training.splitLength,
          onSubmitted: _onsubmittedSplit,
        ),
        NumericField(
          focusNode: lapFocusNode,
          label: 'Lap Distance (${selectedDistUnit.watch(context)})',
          controller: lapController,
          value: widget.training.lapLength,
          onSubmitted: _onsubmittedLap,
        ),
        TextField(
          focusNode: commentsFocusNode,
          controller: commentsController,
          decoration: const InputDecoration(
            label: Text('Comments'),
          ),
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
