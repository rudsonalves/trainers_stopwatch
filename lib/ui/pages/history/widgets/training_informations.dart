import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '/domain/common/training/models/training.dart';
import '/domain/common/user/models/user.dart';
import '/ui/components/theme/app_font_style.dart';

class TrainingInformations extends StatelessWidget {
  final User user;
  final Training training;

  const TrainingInformations({
    super.key,
    required this.user,
    required this.training,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final unit = training.splitDistance.unit.symbol;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(),
        color: colorScheme.secondaryContainer.withValues(alpha: 0.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            user.name,
            overflow: TextOverflow.ellipsis,
            style: AppFontStyle.roboto18SemiBold,
            textAlign: TextAlign.center,
          ),
          const Divider(),
          Text('HPTrainingDistances'.tr(),
              style: AppFontStyle.roboto16SemiBold),
          Text('Lap: ${training.lapDistance.value} $unit'),
          Text('Split: ${training.splitDistance.value} $unit'),
          Text('ETDComments'.tr(),
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(training.comments ?? '-'),
        ],
      ),
    );
  }
}
