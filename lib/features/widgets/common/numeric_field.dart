import 'package:flutter/material.dart';

class NumericField extends StatefulWidget {
  final String? label;
  final bool enable;
  final double? value;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;

  const NumericField({
    super.key,
    this.label,
    this.enable = true,
    this.value,
    required this.controller,
    this.focusNode,
    this.onSubmitted,
    this.onChanged,
  });

  @override
  State<NumericField> createState() => _NumericFieldState();
}

class _NumericFieldState extends State<NumericField> {
  final reInitZeroNumber = RegExp(r'^0[1-9][\.\d]*$');
  String oldValue = '';

  @override
  void initState() {
    super.initState();

    oldValue = widget.value != null ? widget.value.toString() : '0';
    widget.controller.text = oldValue;

    widget.controller.addListener(_validadeNumber);
  }

  void _validadeNumber() {
    String newValue = widget.controller.text;

    // Remove spaces
    if (newValue != newValue.trim()) {
      _setControllerText();
      return;
    }

    // Replace empty string by '0'
    if (newValue.isEmpty) {
      oldValue = '0';
      _setControllerText();
      return;
    }

    // Remove zeros of start of number ('02' -> '2')
    if (reInitZeroNumber.hasMatch(newValue)) {
      oldValue = newValue.substring(1);
      _setControllerText();
      return;
    }

    // Check if is a valid number
    final result = double.tryParse(newValue);
    if (result == null) {
      _setControllerText();
      return;
    }

    oldValue = newValue;
  }

  void _setControllerText() {
    widget.controller.text = oldValue;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: oldValue.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: widget.controller,
        keyboardType: TextInputType.number,
        focusNode: widget.focusNode,
        decoration: InputDecoration(
          label: Text(widget.label ?? ''),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          enabled: widget.enable,
        ),
        onSubmitted: widget.onSubmitted,
        onChanged: widget.onChanged,
      ),
    );
  }
}
