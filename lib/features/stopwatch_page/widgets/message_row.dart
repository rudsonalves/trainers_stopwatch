import 'package:flutter/material.dart';

import '../../../common/icons/stopwatch_icons_icons.dart';

class MessageRow extends StatelessWidget {
  final String message;

  const MessageRow(
    this.message, {
    super.key,
  });

  Row _buildMessageRow(IconData iconData) {
    return Row(
      children: [
        Icon(iconData),
        const SizedBox(width: 8),
        Expanded(child: Text(message)),
      ],
    );
  }

  Row _messageRow() {
    if (message.contains('Start')) {
      return _buildMessageRow(StopwatchIcons.start);
    } else if (message.contains('Split')) {
      return _buildMessageRow(StopwatchIcons.partial);
    } else if (message.contains('Lap')) {
      return _buildMessageRow(StopwatchIcons.lap);
    } else {
      return _buildMessageRow(StopwatchIcons.stop);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 2,
          horizontal: 8,
        ),
        child: _messageRow(),
      ),
    );
  }
}
