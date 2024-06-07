import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../common/theme/app_font_style.dart';
import '../../../models/training_model.dart';
import '../../../models/user_model.dart';
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
