// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final void Function()? onPressed;
  final void Function()? onLongPressed;
  final Widget? icon;

  const CustomIconButton({
    super.key,
    this.onPressed,
    this.onLongPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(32),
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onLongPress: onLongPressed,
          onTap: onPressed,
          child: SizedBox(
            width: 38,
            height: 38,
            child: icon,
          ),
        ),
      ),
    );
  }
}
