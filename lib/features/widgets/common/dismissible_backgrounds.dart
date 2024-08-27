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
