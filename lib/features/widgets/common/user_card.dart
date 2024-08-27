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

import 'package:flutter/material.dart';

import '../../../common/constants.dart';
import '../../../common/models/user_model.dart';
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
        title: Text(
          user.name,
          overflow: TextOverflow.ellipsis,
        ),
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
