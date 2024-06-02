import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../common/theme/app_font_style.dart';
import '../../../../models/history_model.dart';

class EditHistoryDialog extends StatefulWidget {
  final String title;
  final HistoryModel history;

  const EditHistoryDialog({
    super.key,
    required this.title,
    required this.history,
  });

  static Future<bool> open(
    BuildContext context, {
    required String title,
    required HistoryModel history,
  }) async {
    final bool result = await showDialog<bool?>(
          context: context,
          builder: (context) => EditHistoryDialog(
            title: title,
            history: history,
          ),
        ) ??
        false;

    return result;
  }

  @override
  State<EditHistoryDialog> createState() => _EditHistoryDialogState();
}

class _EditHistoryDialogState extends State<EditHistoryDialog> {
  final commentsController = TextEditingController(text: '');
  final commentsFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      commentsController.text = widget.history.comments ?? '';
      FocusScope.of(context).requestFocus(commentsFocusNode);
      commentsController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: commentsController.text.length,
      );
    });
  }

  @override
  void dispose() {
    commentsController.dispose();
    commentsFocusNode.dispose();
    super.dispose();
  }

  void _applyButton() {
    widget.history.comments = commentsController.text;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Center(child: Text('ETDTitle'.tr())),
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      children: [
        const Divider(),
        Center(
          child: Text(
            widget.title,
            style: AppFontStyle.roboto16,
          ),
        ),
        const Divider(),
        TextField(
          focusNode: commentsFocusNode,
          controller: commentsController,
          decoration: InputDecoration(
            label: Text('ETDComments'.tr()),
          ),
        ),
        const SizedBox(height: 12),
        ButtonBar(
          children: [
            FilledButton(
              onPressed: _applyButton,
              child: Text('GenericApply'.tr()),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('GenericCancel'.tr()),
            ),
          ],
        ),
      ],
    );
  }
}
