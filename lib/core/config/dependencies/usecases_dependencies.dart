import 'package:auto_injector/auto_injector.dart';

import '/data/repositories/histories/history_repository.dart';
import '/domain/common/report/services/report_email_service.dart';
import '/domain/common/report/services/report_share_service.dart';
import '/domain/common/report/services/temporary_report_file_storage.dart';
import '/domain/common/report/services/training_report_pdf_renderer.dart';
import '/domain/usecases/reports/build_training_report_use_case.dart';
import '/domain/usecases/reports/deliver_training_report_use_case.dart';
import '/domain/usecases/reports/generate_training_report_file_use_case.dart';
import '/domain/usecases/reports/send_training_report_email_use_case.dart';
import '/domain/usecases/reports/share_training_report_use_case.dart';
import '/domain/usecases/trainings/create_training_use_case.dart';
import '/domain/usecases/trainings/persist_stopwatch_snapshot_use_case.dart';
import '/domain/usecases/users/users_use_case.dart';

void registerUseCasesDependencies(AutoInjector injector) {
  injector
    ..add<UsersUseCase>(UsersUseCase.new)
    ..add<CreateTrainingUseCase>(CreateTrainingUseCase.new)
    ..add<PersistStopwatchSnapshotUseCase>(
      PersistStopwatchSnapshotUseCase.new,
    )
    ..add<BuildTrainingReportUseCase>(
      () => BuildTrainingReportUseCase(
        historyRepository: injector.get<HistoryRepository>(),
      ),
    )
    ..add<GenerateTrainingReportFileUseCase>(
      () => GenerateTrainingReportFileUseCase(
        buildReport: injector.get<BuildTrainingReportUseCase>(),
        renderer: injector.get<TrainingReportPdfRenderer>(),
        fileStorage: injector.get<TemporaryReportFileStorage>(),
      ),
    )
    ..add<DeliverTrainingReportUseCase>(
      () => DeliverTrainingReportUseCase(
        generateFile: injector.get<GenerateTrainingReportFileUseCase>(),
        fileStorage: injector.get<TemporaryReportFileStorage>(),
      ),
    )
    ..add<ShareTrainingReportUseCase>(
      () => ShareTrainingReportUseCase(
        deliverReport: injector.get<DeliverTrainingReportUseCase>(),
        shareService: injector.get<ReportShareService>(),
      ),
    )
    ..add<SendTrainingReportEmailUseCase>(
      () => SendTrainingReportEmailUseCase(
        deliverReport: injector.get<DeliverTrainingReportUseCase>(),
        emailService: injector.get<ReportEmailService>(),
      ),
    );
}
