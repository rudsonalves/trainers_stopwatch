import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorDialog extends StatefulWidget {
  final Color inicialColor;

  const ColorDialog(
    this.inicialColor, {
    super.key,
  });

  static Future<Color> open(BuildContext context, Color iniciatlColor) async {
    final result = await showDialog<Color?>(
      context: context,
      builder: (context) => ColorDialog(iniciatlColor),
    );

    return result ?? iniciatlColor;
  }

  @override
  State<ColorDialog> createState() => _ColorDialogState();
}

class _ColorDialogState extends State<ColorDialog> {
  Color selectedColor = Colors.black;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.inicialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a color'),
      content: SingleChildScrollView(
        child: ColorPicker(
          enableAlpha: false,
          pickerColor: selectedColor,
          onColorChanged: (color) {
            selectedColor = color;
          },
        ),
      ),
      actions: [
        FilledButton.tonal(
          onPressed: () {
            Navigator.pop(context, selectedColor);
          },
          child: Text('GenericApply'.tr()),
        ),
        FilledButton.tonal(
          onPressed: () {
            Navigator.pop(context, widget.inicialColor);
          },
          child: Text('GenericCancel'.tr()),
        ),
      ],
    );
  }
}
