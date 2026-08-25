import 'package:flutter_email_sender/flutter_email_sender.dart';

import '/core/result/result.dart';
import '/domain/common/report/services/report_email_service.dart';

typedef ReportEmailSender = Future<void> Function(Email email);

class ReportEmailServiceImpl implements ReportEmailService {
  final ReportEmailSender _send;

  ReportEmailServiceImpl({
    ReportEmailSender? send,
  }) : _send = send ?? FlutterEmailSender.send;

  @override
  AsyncResult<Unit> send(ReportEmailMessage message) async {
    try {
      final email = Email(
        recipients: message.recipients,
        subject: message.subject,
        body: message.htmlBody,
        isHTML: true,
        attachmentPaths: message.attachments
            .map((attachment) => attachment.path)
            .toList(growable: false),
      );

      await _send(email);

      return const Success(unit);
    } catch (error) {
      return Failure(
        AppError(
          code: AppErrorCode.unexpected,
          message: 'Training report email could not be sent.',
          details: error,
        ),
      );
    }
  }
}
