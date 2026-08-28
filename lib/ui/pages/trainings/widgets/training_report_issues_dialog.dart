import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '/domain/common/report/models/training_report_build_outcome.dart';
import '/domain/common/report/models/training_report_issue.dart';

typedef TrainingReportIssueMessage = String Function(TrainingReportIssue issue);

class TrainingReportIssuesDialog extends StatelessWidget {
  final TrainingReportBuildOutcome outcome;
  final TrainingReportIssueMessage issueMessage;

  const TrainingReportIssuesDialog({
    super.key,
    required this.outcome,
    required this.issueMessage,
  });

  static Future<bool> open(
    BuildContext context, {
    required TrainingReportBuildOutcome outcome,
    required TrainingReportIssueMessage issueMessage,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => TrainingReportIssuesDialog(
            outcome: outcome,
            issueMessage: issueMessage,
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = outcome.hasContent;

    return AlertDialog(
      title: Text(
        canContinue
            ? 'TPReportPartialTitle'.tr()
            : 'TPReportRejectedTitle'.tr(),
      ),
      content: SizedBox(
        width: 420,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 420,
            maxHeight: 360,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                canContinue
                    ? 'TPReportPartialMessage'.tr()
                    : 'TPReportRejectedMessage'.tr(),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: outcome.issues.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final issue = outcome.issues[index];
                    final date = issue.training.date;
                    final dateTime = '${DateFormat.yMd().format(date)} '
                        '${DateFormat.Hm().format(date)}';

                    return Text(
                      '$dateTime — ${issueMessage(issue)}',
                    );
                  },
                ),
              ),
              if (canContinue) ...[
                const SizedBox(height: 12),
                Text(
                  'TPReportPartialValidCount'.tr(
                    args: [outcome.validTrainingCount.toString()],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: canContinue
          ? [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('GenericCancel'.tr()),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('GenericContinue'.tr()),
              ),
            ]
          : [
              FilledButton.tonal(
                onPressed: () => Navigator.pop(context, false),
                child: Text('GenericClose'.tr()),
              ),
            ],
    );
  }
}
