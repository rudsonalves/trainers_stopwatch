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

class MessageRow extends StatelessWidget {
  final MessagesModel message;

  const MessageRow({
    super.key,
    required this.message,
  });

  Row _buildMessageRow(IconData iconData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(iconData, color: message.color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.logTitle,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(message.logSubtitle),
          ],
        ),
      ],
    );
  }

  Row _messageRow() {
    if (message.comments.contains('Start')) {
      return _buildMessageRow(StopwatchIcons.start);
    } else if (message.comments.contains('Split')) {
      return _buildMessageRow(StopwatchIcons.partial);
    } else if (message.comments.contains('Lap')) {
      return _buildMessageRow(StopwatchIcons.lap);
    } else {
      return _buildMessageRow(StopwatchIcons.stop);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(
        vertical: 2,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: message.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _messageRow(),
    );
  }
}
