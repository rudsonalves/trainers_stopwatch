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

import '../../../common/icons/stopwatch_icons_icons.dart';
import '../../../common/models/messages_model.dart';
import 'dismissible_backgrounds.dart';

class DismissibleHistory extends StatefulWidget {
  final MessagesModel message;
  final bool enableDelete;
  final Future<bool> Function(int historyId) editHistory;
  final Future<bool> Function(int historyId) managerDelete;

  const DismissibleHistory({
    super.key,
    required this.message,
    this.enableDelete = true,
    required this.editHistory,
    required this.managerDelete,
  });

  @override
  State<DismissibleHistory> createState() => _DismissibleHistoryState();
}

class _DismissibleHistoryState extends State<DismissibleHistory> {
  Future<void> _editHistory() async {
    await widget.editHistory(widget.message.historyId);
    if (mounted) {
      setState(() {});
    }
  }

  Future<bool> _deleteHistory() async {
    if (!widget.enableDelete) return false;
    final result = await widget.managerDelete(widget.message.historyId);
    return result;
  }

  IconData get iconData {
    switch (widget.message.msgType) {
      case MessageType.isLap:
        return StopwatchIcons.lap;
      case MessageType.isSplit:
        return StopwatchIcons.partial;
      case MessageType.isStarting:
        return StopwatchIcons.start;
      case MessageType.isFinish:
        return StopwatchIcons.stop;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: GlobalKey(),
      background: DismissibleContainers.background(context),
      secondaryBackground: DismissibleContainers.secondaryBackground(
        context,
        enable: widget.enableDelete,
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
        ),
        child: ListTile(
          title: Text(widget.message.title),
          subtitle: Text(widget.message.subTitle),
          leading: Icon(iconData),
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await _editHistory();
        } else if (direction == DismissDirection.endToStart) {
          return await _deleteHistory();
        }
        return false;
      },
    );
  }
}
