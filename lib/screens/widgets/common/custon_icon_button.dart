// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../../../common/theme/app_font_style.dart';

class CustomIconButton extends StatelessWidget {
  final void Function()? onPressed;
  final void Function()? onLongPressed;
  final String? label;
  final Widget icon;

  const CustomIconButton({
    super.key,
    this.onPressed,
    this.onLongPressed,
    required this.icon,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onLongPress: onLongPressed,
          onTap: onPressed,
          child: SizedBox(
            width: 38,
            height: label == null ? 42 : 47,
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: label != null
                  ? Column(
                      children: [
                        icon,
                        const SizedBox(height: 2),
                        Text(
                          label!,
                          style: AppFontStyle.roboto12,
                        ),
                      ],
                    )
                  : icon,
            ),
          ),
        ),
      ),
    );
  }
}
