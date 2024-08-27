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
import '../../../common/models/training_model.dart';
import '../../../common/models/user_model.dart';
import '../../widgets/edit_training_dialog/edit_training_dialog.dart';

class TrainingInformations extends StatelessWidget {
  const TrainingInformations({
    super.key,
    required this.user,
    required this.training,
    required this.lapMessage,
    required this.splitMessage,
  });

  final UserModel user;
  final TrainingModel training;
  final String lapMessage;
  final String splitMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () async {
        await EditTrainingDialog.open(
          context,
          userName: user.name,
          training: training,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(),
          color: colorScheme.secondaryContainer.withOpacity(0.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    user.name,
                    overflow: TextOverflow.ellipsis,
                    style: AppFontStyle.roboto18SemiBold,
                    textAlign: TextAlign.center,
                  ),
                ),
                const Icon(
                  Icons.edit,
                  color: Colors.green,
                ),
              ],
            ),
            const Divider(),
            Text(
              'HPTrainingDistances'.tr(),
              style: AppFontStyle.roboto16SemiBold,
            ),
            Text(lapMessage),
            Text(splitMessage),
            Text(
              'ETDComments'.tr(),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(training.comments ?? '-'),
          ],
        ),
      ),
    );
  }
}
