import 'package:flutter/material.dart';
import 'package:trainers_stopwatch/models/messages_model.dart';

import '../../../common/icons/stopwatch_icons_icons.dart';

class MessageRow extends StatelessWidget {
  final MessagesModel message;

  const MessageRow(
    this.message, {
    super.key,
  });

  Row _buildMessageRow(IconData iconData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(iconData),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(message.body),
          ],
        ),
      ],
    );
  }

  Row _messageRow() {
    if (message.body.contains('Start')) {
      return _buildMessageRow(StopwatchIcons.start);
    } else if (message.body.contains('Split')) {
      return _buildMessageRow(StopwatchIcons.partial);
    } else if (message.body.contains('Lap')) {
      return _buildMessageRow(StopwatchIcons.lap);
    } else {
      return _buildMessageRow(StopwatchIcons.stop);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(
        vertical: 2,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _messageRow(),
    );
  }
}
