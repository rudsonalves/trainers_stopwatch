import 'package:flutter/material.dart';

import '../../../common/constants.dart';
import '../../../common/theme/app_font_style.dart';
import '../../widgets/common/numeric_field.dart';

class LengthLineEdit extends StatefulWidget {
  final String lengthLabel;
  final double length;
  final String lengthUnit;

  const LengthLineEdit({
    super.key,
    required this.lengthLabel,
    required this.length,
    required this.lengthUnit,
  });

  @override
  State<LengthLineEdit> createState() => _LengthLineEditState();
}

class _LengthLineEditState extends State<LengthLineEdit> {
  final lenghtController = TextEditingController();
  final unitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    unitController.text = widget.lengthUnit;
  }

  @override
  void dispose() {
    lenghtController.dispose();
    unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.lengthLabel,
            style: AppFontStyle.roboto16,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: NumericField(
              value: widget.length,
              controller: lenghtController,
            ),
          ),
          DropdownButton<String>(
            dropdownColor: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
            value: unitController.text,
            items: distanceUnits
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                unitController.text = value;
              }
            },
          ),
        ],
      ),
    );
  }
}
