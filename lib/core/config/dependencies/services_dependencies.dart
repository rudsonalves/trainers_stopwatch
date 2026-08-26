import 'package:auto_injector/auto_injector.dart';

import '/data/services/database/database_backup_service.dart';
import '/data/services/database/database_schema.dart';
import '/data/services/database/database_service.dart';
import '/data/services/database/database_service_factory.dart';
import '/data/services/histories/history_mapper.dart';
import '/data/services/histories/history_service.dart';
import '/data/services/images/image_compression_service.dart';
import '/data/services/images/image_compression_service_impl.dart';
import '/data/services/images/image_selection_service.dart';
import '/data/services/images/image_selection_service_impl.dart';
import '/data/services/images/user_image_storage_service.dart';
import '/data/services/images/user_image_storage_service_impl.dart';
import '/data/services/reports/report_email_service_impl.dart';
import '/data/services/reports/report_share_service_impl.dart';
import '/data/services/reports/temporary_report_file_storage_impl.dart';
import '/data/services/reports/training_report_pdf_renderer_impl.dart';
import '/data/services/settings/settings_mapper.dart';
import '/data/services/settings/settings_service.dart';
import '/data/services/trainings/training_mapper.dart';
import '/data/services/trainings/training_service.dart';
import '/data/services/users/user_mapper.dart';
import '/data/services/users/user_service.dart';
import '/domain/common/report/services/report_email_service.dart';
import '/domain/common/report/services/report_share_service.dart';
import '/domain/common/report/services/temporary_report_file_storage.dart';
import '/domain/common/report/services/training_report_pdf_renderer.dart';

void registerServicesDependencies(AutoInjector injector) {
  injector
    ..addInstance<DatabaseSchema>(const DatabaseSchema())
    ..addInstance<DatabaseBackupService>(
      DatabaseBackupService(clock: DateTime.now),
    )
    ..addInstance<SettingsMapper>(const SettingsMapper())
    ..addInstance<HistoryMapper>(const HistoryMapper())
    ..addInstance<UserMapper>(const UserMapper())
    ..addInstance<TrainingMapper>(const TrainingMapper())
    ..addSingleton<DatabaseService>(
      () => createDatabaseService(
        backupService: injector.get<DatabaseBackupService>(),
        schema: injector.get<DatabaseSchema>(),
      ),
    )
    ..add<SettingsService>(SettingsService.new)
    ..add<HistoryService>(HistoryService.new)
    ..add<UserService>(UserService.new)
    ..add<TrainingService>(TrainingService.new)
    ..addSingleton<ImageSelectionService>(ImageSelectionServiceImpl.camera)
    ..addSingleton<ImageCompressionService>(
      ImageCompressionServiceImpl.platform,
    )
    ..addSingleton<UserImageStorageService>(
      UserImageStorageServiceImpl.platform,
    )
    ..addSingleton<TrainingReportPdfRenderer>(
      TrainingReportPdfRendererImpl.new,
    )
    ..addSingleton<TemporaryReportFileStorage>(
      TemporaryReportFileStorageImpl.new,
    )
    ..addSingleton<ReportShareService>(
      ReportShareServiceImpl.new,
    )
    ..addSingleton<ReportEmailService>(
      ReportEmailServiceImpl.new,
    );
}
