import '/core/result/result.dart';
import 'temporary_report_file_storage.dart';

class ReportEmailMessage {
  final List<String> recipients;
  final String subject;
  final String htmlBody;
  final List<TemporaryReportFile> attachments;

  ReportEmailMessage({
    required List<String> recipients,
    required this.subject,
    required this.htmlBody,
    required List<TemporaryReportFile> attachments,
  })  : recipients = List.unmodifiable(recipients),
        attachments = List.unmodifiable(attachments);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ReportEmailMessage &&
            _listEquals(recipients, other.recipients) &&
            subject == other.subject &&
            htmlBody == other.htmlBody &&
            _listEquals(attachments, other.attachments);
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(recipients),
        subject,
        htmlBody,
        Object.hashAll(attachments),
      );

  bool _listEquals<T>(List<T> first, List<T> second) {
    if (identical(first, second)) return true;
    if (first.length != second.length) return false;

    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }

    return true;
  }
}

abstract interface class ReportEmailService {
  AsyncResult<Unit> send(ReportEmailMessage message);
}
