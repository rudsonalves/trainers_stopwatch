import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/data/services/reports/report_email_service_impl.dart';
import 'package:trainers_stopwatch/data/services/reports/report_share_service_impl.dart';
import 'package:trainers_stopwatch/data/services/reports/temporary_report_file_storage_impl.dart';
import 'package:trainers_stopwatch/domain/common/report/services/report_email_service.dart';
import 'package:trainers_stopwatch/domain/common/report/services/temporary_report_file_storage.dart';

void main() {
  group('TemporaryReportFileStorageImpl', () {
    late Directory directory;
    late TemporaryReportFileStorageImpl storage;
    var sequence = 0;

    setUp(() async {
      sequence = 0;

      directory = await Directory.systemTemp.createTemp(
        'training_report_storage_test_',
      );
      storage = TemporaryReportFileStorageImpl(
        directoryProvider: () async => directory,
        uniqueSuffix: () => 'fake_${sequence++}',
      );
    });

    tearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    test('writes bytes with a unique name and returns metadata', () async {
      final result = await storage.write(
        suggestedName: 'training_logs.pdf',
        mimeType: 'application/pdf',
        bytes: Uint8List.fromList([1, 2, 3]),
      );

      expect(result.isSuccess, isTrue);

      final reference = result.value!;
      expect(reference.name, 'training_logs_fake_0.pdf');
      expect(reference.mimeType, 'application/pdf');
      expect(reference.path, '${directory.path}/${reference.name}');
      expect(await File(reference.path).readAsBytes(), [1, 2, 3]);
    });

    test('removes path components from the suggested name', () async {
      final result = await storage.write(
        suggestedName: '../outside/report.pdf',
        mimeType: 'application/pdf',
        bytes: Uint8List.fromList([1]),
      );

      expect(result.isSuccess, isTrue);
      expect(result.value!.name, 'report_fake_0.pdf');
      expect(result.value!.path, startsWith(directory.path));
    });

    test('creates different names for concurrent operations', () async {
      final first = await storage.write(
        suggestedName: 'report.pdf',
        mimeType: 'application/pdf',
        bytes: Uint8List.fromList([1]),
      );
      final second = await storage.write(
        suggestedName: 'report.pdf',
        mimeType: 'application/pdf',
        bytes: Uint8List.fromList([2]),
      );

      expect(first.value!.name, 'report_fake_0.pdf');
      expect(second.value!.name, 'report_fake_1.pdf');
      expect(first.value!.path, isNot(second.value!.path));
    });

    test('rejects an invalid name', () async {
      final result = await storage.write(
        suggestedName: '  ',
        mimeType: 'application/pdf',
        bytes: Uint8List(0),
      );

      expect(result.isFailure, isTrue);
      expect(result.error!.code, AppErrorCode.invalidData);
    });

    test('rejects an empty MIME type', () async {
      final result = await storage.write(
        suggestedName: 'report.pdf',
        mimeType: ' ',
        bytes: Uint8List(0),
      );

      expect(result.isFailure, isTrue);
      expect(result.error!.code, AppErrorCode.invalidData);
    });

    test('maps directory and write failures to AppError', () async {
      final failingStorage = TemporaryReportFileStorageImpl(
        directoryProvider: () async => throw const FileSystemException(
          'directory unavailable',
        ),
      );

      final result = await failingStorage.write(
        suggestedName: 'report.pdf',
        mimeType: 'application/pdf',
        bytes: Uint8List.fromList([1]),
      );

      expect(result.isFailure, isTrue);
      expect(result.error!.code, AppErrorCode.storageWriteFailed);
    });

    test('deletes a file and treats repeated deletion as success', () async {
      final written = await storage.write(
        suggestedName: 'report.pdf',
        mimeType: 'application/pdf',
        bytes: Uint8List.fromList([1]),
      );
      final reference = written.value!;

      final first = await storage.delete(reference);
      final second = await storage.delete(reference);

      expect(first.isSuccess, isTrue);
      expect(second.isSuccess, isTrue);
      expect(await File(reference.path).exists(), isFalse);
    });
  });

  group('ReportShareServiceImpl', () {
    const file = TemporaryReportFile(
      path: '/temporary/report.pdf',
      name: 'report.pdf',
      mimeType: 'application/pdf',
    );

    test('sends the file metadata and subject to share_plus', () async {
      ShareParams? captured;
      final service = ReportShareServiceImpl(
        share: (params) async {
          captured = params;
          return const ShareResult(
            'fake',
            ShareResultStatus.success,
          );
        },
      );

      final result = await service.share(
        file: file,
        subject: 'Training',
      );

      expect(result.isSuccess, isTrue);
      expect(captured!.subject, 'Training');
      expect(captured!.files, hasLength(1));
      expect(captured!.files!.single.path, file.path);
      expect(captured!.files!.single.name, file.name);
      expect(captured!.files!.single.mimeType, file.mimeType);
    });

    test('maps plugin exceptions to AppError', () async {
      final service = ReportShareServiceImpl(
        share: (_) async => throw StateError('share failed'),
      );

      final result = await service.share(
        file: file,
        subject: 'Training',
      );

      expect(result.isFailure, isTrue);
      expect(result.error!.code, AppErrorCode.unexpected);
    });
  });

  group('ReportEmailServiceImpl', () {
    const file = TemporaryReportFile(
      path: '/temporary/report.pdf',
      name: 'report.pdf',
      mimeType: 'application/pdf',
    );

    test('converts the domain message to an HTML plugin email', () async {
      Email? captured;
      final service = ReportEmailServiceImpl(
        send: (email) async {
          captured = email;
        },
      );
      final message = ReportEmailMessage(
        recipients: const ['ana@example.com'],
        subject: 'Training logs',
        htmlBody: '<p>Training</p>',
        attachments: const [file],
      );

      final result = await service.send(message);

      expect(result.isSuccess, isTrue);
      expect(captured!.recipients, ['ana@example.com']);
      expect(captured!.subject, 'Training logs');
      expect(captured!.body, '<p>Training</p>');
      expect(captured!.isHTML, isTrue);
      expect(captured!.attachmentPaths, ['/temporary/report.pdf']);
    });

    test('maps plugin exceptions to AppError', () async {
      final service = ReportEmailServiceImpl(
        send: (_) async => throw StateError('email failed'),
      );
      final message = ReportEmailMessage(
        recipients: const ['ana@example.com'],
        subject: 'Training logs',
        htmlBody: '<p>Training</p>',
        attachments: const [file],
      );

      final result = await service.send(message);

      expect(result.isFailure, isTrue);
      expect(result.error!.code, AppErrorCode.unexpected);
    });
  });
}
