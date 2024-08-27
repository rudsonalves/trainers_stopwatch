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
import 'package:trainers_stopwatch/common/theme/app_font_style.dart';

import '../../../common/models/training_model.dart';
import '../common/numeric_field.dart';
import '../common/simple_spin_box_field.dart';
import 'widgets/color_dialog.dart';
import 'widgets/distance_unit_row.dart';
import 'widgets/speed_unit_row.dart';

class EditTrainingDialog extends StatefulWidget {
  final String userName;
  final TrainingModel training;

  const EditTrainingDialog({
    super.key,
    required this.userName,
    required this.training,
  });

  static Future<bool> open(
    BuildContext context, {
    required String userName,
    required TrainingModel training,
  }) async {
    final bool result = await showDialog<bool?>(
          context: context,
          builder: (context) => EditTrainingDialog(
            userName: userName,
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
  final lapController = TextEditingController(text: '');
  final splitController = TextEditingController(text: '');
  final maxLapController = TextEditingController();
  final commentsController = TextEditingController(text: '');

  final selectedDistUnit = ValueNotifier<String>('m');
  final selectedSpeedUnit = ValueNotifier<String>('m/s');
  final splitLength = ValueNotifier<double>(0);
  final splitMult = ValueNotifier<int>(5);

  late final currentColor = ValueNotifier<Color>(Colors.green);

  @override
  void initState() {
    super.initState();
    currentColor.value = widget.training.color;

    final lapLength = widget.training.lapLength;
    splitLength.value = widget.training.splitLength;
    splitMult.value = (lapLength ~/ splitLength.value);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      lapController.text = lapLength.toString();
      splitController.text = splitLength.value.toString();
      selectedDistUnit.value = widget.training.distanceUnit;
      selectedSpeedUnit.value = widget.training.speedUnit;
      maxLapController.text =
          widget.training.maxlaps?.toString().padLeft(2, '0') ?? '00';
      commentsController.text = widget.training.comments ?? '';
    });
  }

  @override
  void dispose() {
    splitLength.dispose();
    splitMult.dispose();
    lapController.dispose();
    maxLapController.dispose();
    selectedSpeedUnit.dispose();
    selectedDistUnit.dispose();
    super.dispose();
  }

  void _applyButton() {
    final split = splitLength.value;
    widget.training.splitLength = split;
    widget.training.lapLength = double.parse(lapController.text);
    widget.training.distanceUnit = selectedDistUnit.value;
    widget.training.speedUnit = selectedSpeedUnit.value;
    widget.training.maxlaps = maxLaps();
    widget.training.comments = commentsController.text;
    widget.training.color = currentColor.value;
    Navigator.pop(context, true);
  }

  int? maxLaps() {
    int? value = int.tryParse(maxLapController.text);
    return value == 0 ? value = null : value;
  }

  void _onChangedSplit(String value) {
    if (value.isNotEmpty && isNumber(value) && int.parse(value) > 0) {
      splitLength.value = double.parse(value);
      final lapLength = double.parse(lapController.text);
      splitMult.value = (lapLength ~/ splitLength.value);
    }
  }

  bool isNumber(String value) {
    return double.tryParse(value) != null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SimpleDialog(
      backgroundColor: colorScheme.onInverseSurface,
      title: Text(
        widget.userName,
        overflow: TextOverflow.ellipsis,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      children: [
        Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 12, top: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.primaryContainer,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        DistanceUnitRow(
                          label: 'ETDDistanceUnit'.tr(),
                          selectedUnit: selectedDistUnit,
                          selectedSpeedUnit: selectedSpeedUnit,
                        ),
                        SpeedUnitRow(
                          label: 'ETDSpeedUnit'.tr(),
                          selectedSpeedUnit: selectedSpeedUnit,
                          selectedDistUnit: selectedDistUnit,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      color: colorScheme.onInverseSurface,
                      child: Text(
                        'ETDUnits'.tr(),
                        style: AppFontStyle.roboto12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ValueListenableBuilder(
              valueListenable: currentColor,
              builder: (context, value, _) {
                return InkWell(
                  onTap: () async {
                    currentColor.value =
                        await ColorDialog.open(context, currentColor.value);
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: currentColor.value.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Color',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        ValueListenableBuilder(
          valueListenable: selectedDistUnit,
          builder: (context, value, _) => NumericField(
            label: 'ETDSplitDistance'.tr(args: [value]),
            controller: splitController,
            value: widget.training.splitLength,
            onChanged: _onChangedSplit,
          ),
        ),
        AnimatedBuilder(
          animation:
              Listenable.merge([splitLength, selectedDistUnit, splitMult]),
          builder: (context, _) {
            lapController.text =
                (splitLength.value * splitMult.value).toString();

            return Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: lapController,
                    decoration: InputDecoration(
                      label: Text(
                        'ETDLapDistance'.tr(args: [selectedDistUnit.value]),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    splitMult.value++;
                  },
                  icon: const Icon(Icons.add),
                ),
                IconButton(
                  onPressed: () {
                    if (splitMult.value > 1) {
                      splitMult.value--;
                    }
                  },
                  icon: const Icon(Icons.remove),
                ),
              ],
            );
          },
        ),
        TextFormField(
          controller: commentsController,
          decoration: InputDecoration(
            labelText: 'ETDComments'.tr(),
            hintText: 'ETDCommHit'.tr(),
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
        ),
        SimpleSpinBoxField(
          value: widget.training.maxlaps,
          label: Text('ETDNumberLaps'.tr()),
          maxValue: 100,
          controller: maxLapController,
        ),
        OverflowBar(
          children: [
            FilledButton.tonal(
              onPressed: _applyButton,
              child: Text('GenericApply'.tr()),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(context, false),
              child: Text('GenericCancel'.tr()),
            ),
          ],
        ),
      ],
    );
  }
}
