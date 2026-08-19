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

import '../../../domain/common/user/models/user.dart';
import '../../widgets/common/generic_dialog.dart';
import '../../widgets/common/user_card.dart';
import '../../widgets/common/dismissible_backgrounds.dart';

class DismissibleUserTile extends StatelessWidget {
  final User user;
  final void Function(bool, User)? selectUser;
  final Future<bool> Function(User)? editFunction;
  final Future<bool> Function(User)? deleteFunction;
  final bool isChecked;
  final List<int> blockedUserIds;

  const DismissibleUserTile({
    super.key,
    required this.user,
    this.selectUser,
    this.editFunction,
    this.deleteFunction,
    required this.isChecked,
    required this.blockedUserIds,
  });

  void _onTap(BuildContext context) {
    if (!blockedUserIds.contains(user.id!)) {
      if (selectUser != null) {
        selectUser!(!isChecked, user);
      }
    } else {
      GenericDialog.open(
        context,
        title: 'Sorry',
        message:
            'Atleta com cronômetro aberto na página incial. Para removê-lo '
            'acesse a página inicial e remova seu cronêometro de treino.',
        actions: DialogActions.close,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      background: DismissibleContainers.background(context),
      secondaryBackground: DismissibleContainers.secondaryBackground(context),
      key: ValueKey(user.id),
      child: UserCard(
        isChecked: isChecked,
        name: user.name,
        email: user.email,
        phone: user.phone,
        photoReference: user.photoReference,
        onTap: () => _onTap(context),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd && editFunction != null) {
          await editFunction!(user);
          return false;
        } else if (direction == DismissDirection.endToStart &&
            deleteFunction != null) {
          bool action = await deleteFunction!(user);
          return action;
        }
        return false;
      },
    );
  }
}
