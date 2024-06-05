import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../common/theme/app_font_style.dart';
import '../../../models/training_model.dart';
import '../common/numeric_field.dart';
import '../common/simple_spin_box_field.dart';
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
  final splitController = TextEditingController(text: '');
  final lapController = TextEditingController(text: '');
  final maxLapController = TextEditingController();
  final commentsController = TextEditingController(text: '');

  final selectedDistUnit = ValueNotifier<String>('m');
  final selectedSpeedUnit = ValueNotifier<String>('m/s');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
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
      maxLapController.text =
          widget.training.maxlaps?.toString().padLeft(2, '0') ?? '00';
      commentsController.text = widget.training.comments ?? '';
    });
  }

  @override
  void dispose() {
    splitController.dispose();
    lapController.dispose();
    maxLapController.dispose();
    selectedSpeedUnit.dispose();
    selectedDistUnit.dispose();
    super.dispose();
  }

  void _applyButton() {
    final split = splitController.text;
    final lap = lapController.text;
    widget.training.splitLength =
        split != '0' && split.isNotEmpty ? double.parse(split) : 200;
    widget.training.lapLength =
        lap.isNotEmpty && lap != '0' ? double.parse(lap) : 1000;
    widget.training.distanceUnit = selectedDistUnit.value;
    widget.training.speedUnit = selectedSpeedUnit.value;
    widget.training.maxlaps = maxLaps();
    widget.training.comments = commentsController.text;
    Navigator.pop(context, true);
  }

  int? maxLaps() {
    int? value = int.tryParse(maxLapController.text);
    return value == 0 ? value = null : value;
  }

  void _onsubmittedSplit(String value) {
    lapController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: lapController.text.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SimpleDialog(
      backgroundColor: colorScheme.onInverseSurface,
      title: Center(child: Text('ETDTitle'.tr())),
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      children: [
        const Divider(),
        Center(
          child: Text(
            widget.userName,
            overflow: TextOverflow.ellipsis,
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
          label: 'ETDDistanceUnit'.tr(),
          selectedUnit: selectedDistUnit,
          selectedSpeedUnit: selectedSpeedUnit,
        ),
        SpeedUnitRow(
          label: 'ETDSpeedUnit'.tr(),
          selectedSpeedUnit: selectedSpeedUnit,
          selectedDistUnit: selectedDistUnit,
        ),
        ValueListenableBuilder(
          valueListenable: selectedDistUnit,
          builder: (context, value, _) => NumericField(
            label: 'ETDSplitDistance'.tr(args: [value]),
            controller: splitController,
            value: widget.training.splitLength,
            onSubmitted: _onsubmittedSplit,
          ),
        ),
        ValueListenableBuilder(
          valueListenable: selectedDistUnit,
          builder: (context, value, _) => NumericField(
            label: 'ETDLapDistance'.tr(args: [value]),
            controller: lapController,
            value: widget.training.lapLength,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: commentsController,
          decoration: InputDecoration(
            labelText: 'ETDComments'.tr(),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        SimpleSpinBoxField(
          value: widget.training.maxlaps,
          label: Text('ETDNumberLaps'.tr()),
          maxValue: 100,
          controller: maxLapController,
        ),
        const SizedBox(height: 12),
        ButtonBar(
          children: [
            FilledButton(
              onPressed: _applyButton,
              child: Text('GenericApply'.tr()),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('GenericCancel'.tr()),
            ),
          ],
        ),
      ],
    );
  }
}
