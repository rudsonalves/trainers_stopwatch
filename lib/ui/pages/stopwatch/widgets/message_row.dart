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

import '/application/stopwatch/session/stopwatch_session_message.dart';
import '/common/icons/stopwatch_icons_icons.dart';
import '/common/presentation/training_value_formatter.dart';

class MessageRow extends StatelessWidget {
  final StopwatchSessionMessage message;

  const MessageRow({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(message.colorValue);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(
        vertical: 2,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _messageRow(context),
    );
  }

  Row _buildMessageRow(BuildContext context, IconData iconData) {
    final color = Color(message.colorValue);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(iconData, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.userName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(_subtitle),
          ],
        ),
      ],
    );
  }

  Row _messageRow(BuildContext context) {
    final icon = switch (message.type) {
      StopwatchSessionMessageType.started => StopwatchIcons.start,
      StopwatchSessionMessageType.split => StopwatchIcons.partial,
      StopwatchSessionMessageType.lap => StopwatchIcons.lap,
      StopwatchSessionMessageType.finished => StopwatchIcons.stop,
    };
    return _buildMessageRow(context, icon);
  }

  String get _subtitle {
    if (message.type == StopwatchSessionMessageType.started ||
        message.type == StopwatchSessionMessageType.finished) {
      return message.comments;
    }
    final duration = TrainingValueFormatter.formatDuration(message.duration);
    final speed = message.speed;
    if (speed == null) return '${message.label} time: $duration';
    return '${message.label} time: $duration '
        'Speed: ${TrainingValueFormatter.formatSpeed(speed)}';
  }
}
