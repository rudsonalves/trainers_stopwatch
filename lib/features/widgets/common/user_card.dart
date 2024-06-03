import 'package:flutter/material.dart';

import '../../../common/constants.dart';
import '../../../models/user_model.dart';
import 'show_athlete_image.dart';

class UserCard extends StatelessWidget {
  final bool isChecked;
  final UserModel user;
  final void Function()? onTap;

  const UserCard({
    super.key,
    required this.isChecked,
    required this.user,
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
        title: Text(user.name),
        subtitle: Text(
          '${user.email}\n${user.phone}',
        ),
        leading: SizedBox(
          width: photoImageSize,
          height: photoImageSize,
          child: ShowUserImage(user.photo!, size: 40),
        ),
        onTap: onTap,
      ),
    );
  }
}
