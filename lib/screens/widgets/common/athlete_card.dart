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
    return Card(
      elevation: isChecked ? elevationEnable : elevationDisable,
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
