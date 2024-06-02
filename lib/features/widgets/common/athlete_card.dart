import 'package:flutter/material.dart';

import '../../../common/constants.dart';
import '../../../models/athlete_model.dart';
import 'show_athlete_image.dart';

class AthleteCard extends StatelessWidget {
  final bool isChecked;
  final AthleteModel athlete;
  final void Function()? onTap;

  const AthleteCard({
    super.key,
    required this.isChecked,
    required this.athlete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isChecked
            ? colorScheme.tertiaryContainer.withOpacity(0.5)
            : colorScheme.surfaceBright,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        title: Text(athlete.name),
        subtitle: Text(
          '${athlete.email}\n${athlete.phone}',
        ),
        leading: SizedBox(
          width: photoImageSize,
          height: photoImageSize,
          child: ShowAthleteImage(athlete.photo!, size: 40),
        ),
        onTap: onTap,
      ),
    );
  }
}
