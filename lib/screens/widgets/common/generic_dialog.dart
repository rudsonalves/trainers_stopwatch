import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum DialogActions {
  yesNo,
  addCancel,
  close,
  none,
}

class GenericDialog extends StatelessWidget {
  final String title;
  final List<Widget> content;
  final List<Widget>? actions;

  const GenericDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
  });

  static Future<bool> open(
    BuildContext context, {
    required String title,
    required String message,
    DialogActions actions = DialogActions.none,
  }) async {
    List<Widget> listActions = [];

    switch (actions) {
      case DialogActions.yesNo:
        listActions.add(
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('GenericYes'.tr()),
          ),
        );
        listActions.add(
          ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('GenericNo'.tr()),
          ),
        );
        break;
      case DialogActions.addCancel:
        listActions.add(
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('GenericAdd'.tr()),
          ),
        );
        listActions.add(
          ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('GenericCancel'.tr()),
          ),
        );
        break;
      case DialogActions.close:
        listActions.add(
          ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('GenericClose'.tr()),
          ),
        );
        break;
      case DialogActions.none:
        break;
    }

    bool result = await showDialog<bool?>(
          context: context,
          builder: (context) => GenericDialog(
            title: title,
            content: [
              Text(message),
            ],
            actions: listActions.isEmpty ? null : listActions,
          ),
        ) ??
        false;

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(color: primary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...content,
        ],
      ),
      actions: actions,
    );
  }
}
