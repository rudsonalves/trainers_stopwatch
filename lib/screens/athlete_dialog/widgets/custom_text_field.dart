import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String label;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        label: Text(label),
      ),
    );
  }
}
