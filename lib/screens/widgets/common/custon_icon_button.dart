// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../../common/singletons/app_settings.dart';
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
    final settings = AppSettings.instance;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        color: settings.brightnessMode.watch(context) == Brightness.light
            ? colorScheme.onPrimary.withOpacity(0.3)
            : colorScheme.primary.withOpacity(0.2),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          child: InkWell(
            borderRadius: BorderRadius.circular(5),
            onLongPress: onLongPressed,
            onTap: onPressed,
            child: SizedBox(
              width: 48,
              height: label == null ? 48 : 54,
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: label != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
      ),
    );
  }
}
