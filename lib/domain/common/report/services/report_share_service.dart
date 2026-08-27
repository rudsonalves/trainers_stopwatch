import '/core/result/result.dart';
import 'temporary_report_file_storage.dart';

abstract interface class ReportShareService {
  AsyncResult<Unit> share({
    required TemporaryReportFile file,
    required String subject,
  });
}
