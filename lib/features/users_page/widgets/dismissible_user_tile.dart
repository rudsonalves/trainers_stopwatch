import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:trainers_stopwatch/features/widgets/common/generic_dialog.dart';

import '../../../models/user_model.dart';
import '../../widgets/common/user_card.dart';
import '../../widgets/common/dismissible_backgrounds.dart';

class DismissibleUserTile extends StatefulWidget {
  final UserModel user;
  final void Function(bool, UserModel)? selectUser;
  final Future<bool> Function(UserModel)? editFunction;
  final Future<bool> Function(UserModel)? deleteFunction;
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

  @override
  State<DismissibleUserTile> createState() => _DismissibleUserTileState();
}

class _DismissibleUserTileState extends State<DismissibleUserTile> {
  late final Signal<bool> isChecked;

  @override
  void initState() {
    isChecked = signal(widget.isChecked);

    super.initState();
  }

  @override
  void dispose() {
    isChecked.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!widget.blockedUserIds.contains(widget.user.id!)) {
      isChecked.value = !isChecked();
      if (widget.selectUser != null) {
        widget.selectUser!(isChecked(), widget.user);
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
      key: GlobalKey(),
      child: UserCard(
        isChecked: isChecked.watch(context),
        user: widget.user,
        onTap: _onTap,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd &&
            widget.editFunction != null) {
          await widget.editFunction!(widget.user);
          return false;
        } else if (direction == DismissDirection.endToStart &&
            widget.deleteFunction != null) {
          bool action = await widget.deleteFunction!(widget.user);
          return action;
        }
        return false;
      },
    );
  }
}
