import 'dart:io';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../../common/constants.dart';
import '../../../models/athlete_model.dart';
import '../../widgets/common/dismissible_backgrounds.dart';

class DismissibleAthleteTile extends StatefulWidget {
  final AthleteModel athlete;
  final void Function(bool, AthleteModel)? selectAthlete;

  const DismissibleAthleteTile({
    super.key,
    required this.athlete,
    this.selectAthlete,
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
      background: DismissibleContainers.background(),
      secondaryBackground: DismissibleContainers.secondaryBackground(),
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
            child: Image.file(File(widget.athlete.photo!)),
          ),
          trailing: IconButton(
            onPressed: () {
              isChecked.value = !isChecked.value;
              if (widget.selectAthlete != null) {
                widget.selectAthlete!(isChecked.value, widget.athlete);
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
        return false;
      },
    );
  }
}
