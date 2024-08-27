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
