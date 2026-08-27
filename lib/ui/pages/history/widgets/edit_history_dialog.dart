import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '/ui/components/theme/app_font_style.dart';

class EditHistoryDialog extends StatefulWidget {
  final String title;
  final String? comments;

  const EditHistoryDialog({
    super.key,
    required this.title,
    this.comments,
  });

  static Future<String?> open(
    BuildContext context, {
    required String title,
    String? comments,
  }) =>
      showDialog<String>(
        context: context,
        builder: (context) => EditHistoryDialog(
          title: title,
          comments: comments,
        ),
      );

  @override
  State<EditHistoryDialog> createState() => _EditHistoryDialogState();
}

class _EditHistoryDialogState extends State<EditHistoryDialog> {
  late final commentsController = TextEditingController(
    text: widget.comments ?? '',
  );
  final commentsFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      commentsFocusNode.requestFocus();
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

  @override
  Widget build(BuildContext context) => SimpleDialog(
        title: Center(child: Text('ETDTitle'.tr())),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        children: [
          const Divider(),
          Center(child: Text(widget.title, style: AppFontStyle.roboto16)),
          const Divider(),
          TextField(
            maxLines: 2,
            focusNode: commentsFocusNode,
            controller: commentsController,
            decoration: InputDecoration(label: Text('ETDComments'.tr())),
          ),
          const SizedBox(height: 12),
          OverflowBar(
            children: [
              FilledButton.tonal(
                onPressed: () => Navigator.pop(
                  context,
                  commentsController.text,
                ),
                child: Text('GenericApply'.tr()),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(context),
                child: Text('GenericCancel'.tr()),
              ),
            ],
          ),
        ],
      );
}
