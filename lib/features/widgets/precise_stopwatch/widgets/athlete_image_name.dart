import 'package:flutter/material.dart';

import '../../common/show_athlete_image.dart';

class AthleteImageName extends StatelessWidget {
  const AthleteImageName({
    super.key,
    required this.image,
    required this.name,
  });

  final String image;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShowAthleteImage(image),
        const SizedBox(height: 4),
        SizedBox(
          width: 70,
          child: Text(
            name.split(' ').first,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
