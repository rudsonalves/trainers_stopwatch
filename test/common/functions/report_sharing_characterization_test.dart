import 'dart:convert';
import 'dart:io';

import 'package:flutter_email_sender_platform_interface/flutter_email_sender_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';
import 'package:trainers_stopwatch/common/functions/build_pdf.dart';
import 'package:trainers_stopwatch/common/functions/share_functions.dart';
import 'package:trainers_stopwatch/common/functions/training_report.dart';
import 'package:trainers_stopwatch/common/models/history_model.dart';
import 'package:trainers_stopwatch/common/models/messages_model.dart';
import 'package:trainers_stopwatch/common/models/training_model.dart';
import 'package:trainers_stopwatch/common/models/user_model.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/data/repositories/histories/history_repository.dart';
import 'package:trainers_stopwatch/domain/common/history/models/history_entry.dart';
import 'package:trainers_stopwatch/domain/common/training/models/training.dart';
import 'package:trainers_stopwatch/domain/common/user/models/user.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory temporaryDirectory;
  late _FakeHistoryRepository historyRepository;
  late _FakePathProvider pathProvider;
  late _FakeEmailSender emailSender;
  late _FakeSharePlatform sharePlatform;

  setUpAll(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'trainers_stopwatch_report_characterization_',
    );
    pathProvider = _FakePathProvider(temporaryDirectory.path);
    emailSender = _FakeEmailSender();
    sharePlatform = _FakeSharePlatform();

    PathProviderPlatform.instance = pathProvider;
    FlutterEmailSenderPlatform.instance = emailSender;
    SharePlatform.instance = sharePlatform;
  });

  setUp(() {
    historyRepository = _FakeHistoryRepository();
    emailSender.sent.clear();
    sharePlatform.shared.clear();
  });

  tearDown(() async {
    final report = File('${temporaryDirectory.path}/training_logs.pdf');
    if (await report.exists()) await report.delete();
  });

  tearDownAll(() async {
    await temporaryDirectory.delete(recursive: true);
  });

  group('legacy report content', () {
    test('preserves event order, labels, units, durations, and comments', () {
      final report = TrainingReport(
        user: UserModel(id: 1, name: 'Ana', email: 'ana@example.com'),
        training: _legacyTraining(id: 10),
        histories: [
          _legacyHistory(id: 1, duration: Duration.zero, comments: 'start'),
          _legacyHistory(
            id: 2,
            duration: const Duration(seconds: 20),
            comments: 'first split',
          ),
          _legacyHistory(
            id: 3,
            duration: const Duration(seconds: 21),
            comments: 'second split',
          ),
          _legacyHistory(
            id: 4,
            duration: const Duration(seconds: 22),
            comments: 'third split',
          ),
          _legacyHistory(
            id: 5,
            duration: const Duration(seconds: 23),
            comments: 'fourth split',
          ),
          _legacyHistory(
            id: 6,
            duration: const Duration(seconds: 24),
            comments: 'lap comment',
          ),
        ],
      );

      report.createMessages();

      expect(
        report.messages.map((message) => message.msgType),
        [
          MessageType.isStarting,
          MessageType.isSplit,
          MessageType.isSplit,
          MessageType.isSplit,
          MessageType.isSplit,
          MessageType.isSplit,
          MessageType.isLap,
        ],
      );
      expect(
        report.messages.map((message) => message.label),
        [
          'HPCTrainingStarting',
          'Split[1]',
          'Split[2]',
          'Split[3]',
          'Split[4]',
          'Split[5]',
          'Lap[1]',
        ],
      );
      expect(report.messages[1].duration, const Duration(seconds: 20));
      expect(report.messages[1].speedString, '10.00 m/s');
      expect(report.messages[1].comments, 'first split');
      expect(report.messages.last.duration, const Duration(seconds: 110));
      expect(report.messages.last.speedString, '9.09 m/s');
      expect(report.messages.last.comments, 'lap comment');
    });

    test('represents a training without splits with no report rows', () {
      final report = TrainingReport(
        user: UserModel(id: 1, name: 'Ana', email: 'ana@example.com'),
        training: _legacyTraining(id: 10),
        histories: const [],
      );

      report.createMessages();

      expect(report.messages, isEmpty);
    });
  });

  group('legacy PDF', () {
    test('loads each page training in order and creates a non-empty PDF',
        () async {
      historyRepository.historiesByTraining.addAll({
        10: [
          _history(id: 1, trainingId: 10, duration: Duration.zero),
          _history(
            id: 2,
            trainingId: 10,
            duration: const Duration(seconds: 20),
          ),
        ],
        20: [
          _history(id: 3, trainingId: 20, duration: Duration.zero),
          _history(
            id: 4,
            trainingId: 20,
            duration: const Duration(seconds: 21),
          ),
        ],
      });

      final file = await BuildPdf.makeReport(
        UserModel(id: 1, name: 'Ana', email: 'ana@example.com'),
        [_legacyTraining(id: 20), _legacyTraining(id: 10)],
        historyRepository,
      );

      expect(historyRepository.loadedTrainingIds, [20, 10]);
      expect(await file.exists(), isTrue);
      expect(file.path, endsWith('/training_logs.pdf'));
      expect(await file.length(), greaterThan(0));
    });

    test('creates a zero-page PDF when no trainings are selected', () async {
      final file = await BuildPdf.makeReport(
        UserModel(id: 1, name: 'Ana', email: 'ana@example.com'),
        const [],
        historyRepository,
      );

      expect(historyRepository.loadedTrainingIds, isEmpty);
      expect(await file.exists(), isTrue);
      expect(await _pdfPageCount(file), 0);
    });

    test('fails with zero elapsed time for a training without partials',
        () async {
      historyRepository.historiesByTraining[10] = [
        _history(id: 1, trainingId: 10, duration: Duration.zero),
      ];

      await expectLater(
        BuildPdf.makeReport(
          UserModel(id: 1, name: 'Ana', email: 'ana@example.com'),
          [_legacyTraining(id: 10)],
          historyRepository,
        ),
        throwsA(
          isA<AppError>().having(
            (error) => error.code,
            'code',
            AppErrorCode.zeroElapsedTime,
          ),
        ),
      );
    });
  });

  group('legacy external delivery', () {
    test('sends an HTML email with the current subject, body, and attachment',
        () async {
      historyRepository.historiesByTraining[10] = [
        _history(id: 1, trainingId: 10, duration: Duration.zero),
        _history(
          id: 2,
          trainingId: 10,
          duration: const Duration(seconds: 20),
        ),
      ];
      final appShare = AppShare(historyRepository: historyRepository);

      await appShare.sendEmail(
        user: _user,
        recipient: _user.email,
        trainings: [_training(id: 10, comments: 'steady')],
      );

      expect(emailSender.sent, hasLength(1));
      final email = emailSender.sent.single;
      expect(email.subject, 'Training logs');
      expect(email.recipients, ['ana@example.com']);
      expect(email.isHTML, isTrue);
      expect(email.attachmentPaths, hasLength(1));
      expect(
          email.body,
          contains(
              '<h1 style="font-size: 24px; color: #333;">Training Logs</h1>'));
      expect(email.body, contains('<h2>Training</h2>'));
      expect(email.body,
          contains('<p><strong>Split Length:</strong> 200.0 m</p>'));
      expect(
          email.body, contains('<p><strong>Lap Length:</strong> 1000.0 m</p>'));
      expect(email.body, contains('<p><strong>Comments:</strong> steady</p>'));
      expect(await File(email.attachmentPaths!.single).exists(), isFalse);
    });

    test('shares one PDF with the current subject and leaves the file present',
        () async {
      historyRepository.historiesByTraining[10] = [
        _history(id: 1, trainingId: 10, duration: Duration.zero),
        _history(
          id: 2,
          trainingId: 10,
          duration: const Duration(seconds: 20),
        ),
      ];
      final appShare = AppShare(historyRepository: historyRepository);

      await appShare.sendWhatsApp(
        user: _user,
        trainings: [_training(id: 10)],
      );

      expect(sharePlatform.shared, hasLength(1));
      final params = sharePlatform.shared.single;
      expect(params.subject, 'Training');
      expect(params.files, hasLength(1));
      expect(params.files!.single.path, endsWith('/training_logs.pdf'));
      expect(await File(params.files!.single.path).exists(), isTrue);
    });
  });
}

const _user = User(id: 1, name: 'Ana', email: 'ana@example.com');

Training _training({required int id, String? comments}) => Training.create(
      id: id,
      userId: 1,
      date: DateTime(2026, 8, 25, 10, 30),
      comments: comments,
    ).value!;

TrainingModel _legacyTraining({required int id}) => TrainingModel(
      id: id,
      userId: 1,
      date: DateTime(2026, 8, 25, 10, 30),
      splitLength: 200,
      lapLength: 1000,
    );

HistoryModel _legacyHistory({
  required int id,
  required Duration duration,
  String? comments,
}) =>
    HistoryModel(
      id: id,
      trainingId: 10,
      duration: duration,
      comments: comments,
    );

HistoryEntry _history({
  required int id,
  required int trainingId,
  required Duration duration,
  String? comments,
}) =>
    HistoryEntry.create(
      id: id,
      trainingId: trainingId,
      duration: duration,
      comments: comments,
    ).value!;

Future<int> _pdfPageCount(File file) async {
  final bytes = await file.readAsBytes();
  final contents = latin1.decode(bytes, allowInvalid: true);
  expect(contents, startsWith('%PDF-'));
  return RegExp(r'/Type /Page\b').allMatches(contents).length;
}

final class _FakeHistoryRepository implements HistoryRepository {
  final Map<int, List<HistoryEntry>> historiesByTraining = {};
  final List<int> loadedTrainingIds = [];

  @override
  List<HistoryEntry> historiesForTraining(int trainingId) =>
      List.unmodifiable(historiesByTraining[trainingId] ?? const []);

  @override
  AsyncResult<List<HistoryEntry>> loadForTraining(int trainingId) async {
    loadedTrainingIds.add(trainingId);
    return Success(historiesForTraining(trainingId));
  }

  @override
  AsyncResult<Unit> deleteAndMergeNext({
    required int trainingId,
    required int historyEntryId,
  }) =>
      throw UnimplementedError();

  @override
  AsyncResult<HistoryEntry> insert(HistoryEntry entry) =>
      throw UnimplementedError();

  @override
  AsyncResult<HistoryEntry> insertIdempotent(HistoryEntry entry) =>
      throw UnimplementedError();

  @override
  AsyncResult<Unit> update(HistoryEntry entry) => throw UnimplementedError();
}

final class _FakePathProvider extends PathProviderPlatform {
  final String path;

  _FakePathProvider(this.path);

  @override
  Future<String?> getTemporaryPath() async => path;
}

final class _FakeEmailSender extends FlutterEmailSenderPlatform {
  final List<Email> sent = [];

  @override
  Future<void> send(Email email) async => sent.add(email);

  @override
  Future<EmailCapabilities> getCapabilities() async =>
      const EmailCapabilities.none();
}

final class _FakeSharePlatform extends SharePlatform {
  final List<ShareParams> shared = [];

  @override
  Future<ShareResult> share(ShareParams params) async {
    shared.add(params);
    return const ShareResult('fake', ShareResultStatus.success);
  }
}
