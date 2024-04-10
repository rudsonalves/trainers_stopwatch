import 'package:flutter/material.dart';

// FIXME: add to StopwatchWidgets dismissibles
class DismissibleContainers {
  DismissibleContainers._();

  static Container background([
    bool enable = true,
  ]) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.green.withOpacity(0.3),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.edit),
            SizedBox(width: 8),
            Text(
              'Edit',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  static Container secondaryBackground([
    bool enable = true,
  ]) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.red.withOpacity(0.3),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(width: 8),
            Icon(Icons.remove_circle),
          ],
        ),
      ),
    );
  }
}
