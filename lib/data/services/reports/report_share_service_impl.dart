import 'package:share_plus/share_plus.dart';

import '/core/result/result.dart';
import '/domain/common/report/services/report_share_service.dart';
import '/domain/common/report/services/temporary_report_file_storage.dart';

typedef ReportShareInvoker = Future<ShareResult> Function(
  ShareParams params,
);

class ReportShareServiceImpl implements ReportShareService {
  final ReportShareInvoker _share;

  ReportShareServiceImpl({
    ReportShareInvoker? share,
  }) : _share = share ?? SharePlus.instance.share;

  @override
  AsyncResult<Unit> share({
    required TemporaryReportFile file,
    required String subject,
  }) async {
    try {
      await _share(
        ShareParams(
          files: [
            XFile(
              file.path,
              name: file.name,
              mimeType: file.mimeType,
            ),
          ],
          subject: subject,
        ),
      );

      return const Success(unit);
    } catch (error) {
      return Failure(
        AppError(
          code: AppErrorCode.unexpected,
          message: 'Training report could not be shared.',
          details: error,
        ),
      );
    }
  }
}
