import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../../common/constants.dart';
import '../../../models/athlete_model.dart';
import '../../widgets/common/dismissible_backgrounds.dart';
import '../../widgets/common/show_athlete_image.dart';

class DismissibleAthleteTile extends StatefulWidget {
  final AthleteModel athlete;
  final void Function(bool, AthleteModel)? selectAthlete;
  final Future<bool> Function(AthleteModel)? editFunction;
  final Future<bool> Function(AthleteModel)? deleteFunction;

  const DismissibleAthleteTile({
    super.key,
    required this.athlete,
    this.selectAthlete,
    this.editFunction,
    this.deleteFunction,
  });

  @override
  State<DismissibleAthleteTile> createState() => _DismissibleAthleteTileState();
}

class _DismissibleAthleteTileState extends State<DismissibleAthleteTile> {
  final isChecked = signal(false);

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;

    return Dismissible(
      background: DismissibleContainers.background(context),
      secondaryBackground: DismissibleContainers.secondaryBackground(context),
      key: GlobalKey(),
      child: Card(
        elevation: 10,
        child: ListTile(
          title: Text(widget.athlete.name),
          subtitle: Text(
            '${widget.athlete.email}\n${widget.athlete.phone}',
          ),
          leading: SizedBox(
            width: photoImageSize,
            height: photoImageSize,
            child: ShowAthleteImage(widget.athlete.photo!, size: 40),
          ),
          trailing: IconButton(
            onPressed: () {
              isChecked.value = !isChecked();
              if (widget.selectAthlete != null) {
                widget.selectAthlete!(isChecked(), widget.athlete);
              }
            },
            icon: Icon(
              isChecked.watch(context) ? Icons.task_alt : Icons.circle_outlined,
              color: isChecked.value ? Colors.green : secondary,
            ),
          ),
        ),
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
