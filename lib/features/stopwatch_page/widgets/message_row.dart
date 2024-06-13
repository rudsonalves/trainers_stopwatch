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
