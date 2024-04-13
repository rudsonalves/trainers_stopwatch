import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signals/signals_flutter.dart';

import '../../../common/theme/app_font_style.dart';
import '../../../models/training_model.dart';
import 'numeric_field.dart';

class SetDistancesDialog extends StatefulWidget {
  final String athleteName;
  final TrainingModel training;

  const SetDistancesDialog({
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
          builder: (context) => SetDistancesDialog(
            athleteName: athleteName,
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
  final selectedDistUnit = signal<String>('m');
  List<String> distanceUnits = ['m', 'km', 'yd', 'mi'];
  final selectedSpeedUnit = signal<String>('m/s');
  List<String> speedUnits = ['m/s', 'km/h', 'yd/s', 'mph'];
  final speedAllowedValues = {
    'm': ['m/s', 'km/h'],
    'km': ['m/s', 'km/h'],
    'yd': ['yd/s', 'mph'],
    'mi': ['yd/s', 'm/s', 'mph'],
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FocusScope.of(context).requestFocus(splitFocusnode);
      splitController.text = widget.training.splitLength.toString();
      lapController.text = widget.training.lapLength.toString();
      selectedDistUnit.value = widget.training.distanceUnit;
      selectedSpeedUnit.value = widget.training.speedUnit;
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
        split != '0' && split.isNotEmpty ? double.parse(split) : 200;
    widget.training.lapLength =
        lap.isNotEmpty && lap != '0' ? double.parse(lap) : 1000;
    widget.training.distanceUnit = selectedDistUnit();
    widget.training.speedUnit = selectedSpeedUnit();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final colorscheme = Theme.of(context).colorScheme;

    return SimpleDialog(
      title: const Center(child: Text('Training Settings')),
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      children: [
        const Divider(),
        Center(
          child: Text(
            widget.athleteName,
            style: AppFontStyle.roboto18Bold,
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
        Row(
          children: [
            const Text('Distance Unit:'),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: selectedDistUnit(),
              items: distanceUnits
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedDistUnit.value = value;
                  if (!speedAllowedValues[value]!
                      .contains(selectedSpeedUnit())) {
                    selectedSpeedUnit.value = speedAllowedValues[value]!.first;
                  }
                }
              },
            ),
          ],
        ),
        Row(
          children: [
            const Text('Speed Unit:'),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: selectedSpeedUnit(),
              items: speedUnits.map(
                (item) {
                  final enable =
                      speedAllowedValues[selectedDistUnit.watch(context)]!
                          .contains(item);
                  return DropdownMenuItem(
                    enabled: enable,
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(
                        color: enable
                            ? colorscheme.onSurface
                            : colorscheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                  );
                },
              ).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedSpeedUnit.value = value;
                }
              },
            ),
          ],
        ),
        NumericField(
          focusNode: splitFocusnode,
          label: 'Split Distance (${selectedDistUnit.watch(context)})',
          controller: splitController,
          value: widget.training.splitLength,
          onSubmitted: (_) => FocusScope.of(context).requestFocus(lapFocusNode),
        ),
        NumericField(
          focusNode: lapFocusNode,
          label: 'Lap Distance (${selectedDistUnit.watch(context)})',
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
