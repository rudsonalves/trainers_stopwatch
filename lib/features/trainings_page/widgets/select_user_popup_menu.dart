import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../common/singletons/app_settings.dart';
import '../../../common/theme/app_font_style.dart';
import '../trainings_page_controller.dart';

class SelectUserPopupMenu extends StatelessWidget {
  const SelectUserPopupMenu({
    super.key,
    required this.colorScheme,
    required this.controller,
  });

  final ColorScheme colorScheme;
  final TrainingsPageController controller;

  @override
  Widget build(BuildContext context) {
    final app = AppSettings.instance;

    return Row(
      children: [
        Text(
          'TPSelectUser'.tr(),
          style: AppFontStyle.roboto16,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Focus(
              focusNode: app.focusNodes[23],
              child: DropdownButton<int>(
                isExpanded: true,
                borderRadius: BorderRadius.circular(12),
                dropdownColor: colorScheme.primaryContainer,
                value: controller.userId,
                items: controller.users
                    .map(
                      (user) => DropdownMenuItem<int>(
                        value: user.id!,
                        child: Text(
                          user.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: controller.selectUser,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
