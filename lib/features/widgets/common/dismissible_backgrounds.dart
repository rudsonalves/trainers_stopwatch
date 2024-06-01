import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../common/theme/app_font_style.dart';

class DismissibleContainers {
  DismissibleContainers._();

  static Container background(
    BuildContext context, {
    bool enable = true,
    String? label,
    IconData iconData = Icons.edit,
    Color color = Colors.green,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    label = label ?? 'GenericEdit'.tr();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withOpacity(0.3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              iconData,
              color: enable ? null : primary.withOpacity(0.3),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppFontStyle.roboto16.copyWith(
                color: enable ? null : primary.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Container secondaryBackground(
    BuildContext context, {
    bool enable = true,
    String? label,
    IconData iconData = Icons.remove_circle,
    Color color = Colors.red,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    label = label ?? 'GenericDelete'.tr();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withOpacity(0.3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              label,
              style: AppFontStyle.roboto16.copyWith(
                color: enable ? null : primary.withOpacity(0.3),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              iconData,
              color: enable ? null : primary.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
