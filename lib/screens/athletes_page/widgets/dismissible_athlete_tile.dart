import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../../models/athlete_model.dart';
import '../../widgets/common/athlete_card.dart';
import '../../widgets/common/dismissible_backgrounds.dart';

class DismissibleAthleteTile extends StatefulWidget {
  final AthleteModel athlete;
  final void Function(bool, AthleteModel)? selectAthlete;
  final Future<bool> Function(AthleteModel)? editFunction;
  final Future<bool> Function(AthleteModel)? deleteFunction;
  final bool isChecked;
  final List<int> blockedAthleteIds;

  const DismissibleAthleteTile({
    super.key,
    required this.athlete,
    this.selectAthlete,
    this.editFunction,
    this.deleteFunction,
    required this.isChecked,
    required this.blockedAthleteIds,
  });

  @override
  State<DismissibleAthleteTile> createState() => _DismissibleAthleteTileState();
}

class _DismissibleAthleteTileState extends State<DismissibleAthleteTile> {
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
    if (!widget.blockedAthleteIds.contains(widget.athlete.id!)) {
      isChecked.value = !isChecked();
      if (widget.selectAthlete != null) {
        widget.selectAthlete!(isChecked(), widget.athlete);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      background: DismissibleContainers.background(context),
      secondaryBackground: DismissibleContainers.secondaryBackground(context),
      key: GlobalKey(),
      child: AthleteCard(
        isChecked: isChecked.watch(context),
        athlete: widget.athlete,
        onTap: _onTap,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd &&
            widget.editFunction != null) {
          await widget.editFunction!(widget.athlete);
          return false;
        } else if (direction == DismissDirection.endToStart &&
            widget.deleteFunction != null) {
          bool action = await widget.deleteFunction!(widget.athlete);
          return action;
        }
        return false;
      },
    );
  }
}
