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
