import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/result.dart';
import 'package:trainers_stopwatch/data/repositories/trainings/training_repository.dart';
import 'package:trainers_stopwatch/data/repositories/users/user_repository.dart';
import 'package:trainers_stopwatch/domain/common/report/models/training_report_build_outcome.dart';
import 'package:trainers_stopwatch/domain/common/report/models/training_report_content.dart';
import 'package:trainers_stopwatch/domain/common/report/models/training_report_issue.dart';
import 'package:trainers_stopwatch/domain/common/report/models/training_report_section.dart';
import 'package:trainers_stopwatch/domain/common/report/models/training_report_totals.dart';
import 'package:trainers_stopwatch/domain/common/report/services/training_report_pdf_renderer.dart';
import 'package:trainers_stopwatch/domain/common/training/models/training.dart';
import 'package:trainers_stopwatch/domain/common/training/values/distance.dart';
import 'package:trainers_stopwatch/domain/common/training/values/speed.dart';
import 'package:trainers_stopwatch/domain/common/user/models/user.dart';
import 'package:trainers_stopwatch/domain/usecases/reports/build_training_report_use_case.dart';
import 'package:trainers_stopwatch/domain/usecases/reports/send_training_report_email_use_case.dart';
import 'package:trainers_stopwatch/domain/usecases/reports/share_training_report_use_case.dart';
import 'package:trainers_stopwatch/ui/pages/trainings/viewmodel/models/email_prepared_training_report_command_input.dart';
import 'package:trainers_stopwatch/ui/pages/trainings/viewmodel/models/share_prepared_training_report_command_input.dart';
import 'package:trainers_stopwatch/ui/pages/trainings/viewmodel/models/training_report_command_inputs.dart';
import 'package:trainers_stopwatch/ui/pages/trainings/viewmodel/models/training_selection_state.dart';
import 'package:trainers_stopwatch/ui/pages/trainings/viewmodel/trainings_view_model.dart';

const readFailure = AppError(
  code: AppErrorCode.storageReadFailed,
  message: 'read failed',
);

const writeFailure = AppError(
  code: AppErrorCode.storageWriteFailed,
  message: 'write failed',
);

const reportFailure = AppError(
  code: AppErrorCode.unknown,
  message: 'report failed',
);

class _UserRepositoryFake implements UserRepository {
  List<User> stored = const [];
  List<User> _cache = const [];
  bool failLoad = false;

  @override
  List<User> get users => _cache;

  @override
  AsyncResult<List<User>> loadAll() async {
    if (failLoad) return const Failure(readFailure);
    _cache = List.unmodifiable(stored);
    return Success(_cache);
  }

  @override
  AsyncResult<User> insert(User user) async => Success(user);

  @override
  AsyncResult<Unit> update(User user) async => const Success(unit);

  @override
  AsyncResult<Unit> delete(int id) async => const Success(unit);

  @override
  AsyncResult<List<String>> readPhotoReferences() async => const Success([]);
}

class _TrainingRepositoryFake implements TrainingRepository {
  final Map<int, List<Training>> stored = {};
  final Map<int, List<Training>> _cache = {};
  bool failLoad = false;
  int? failDeleteId;
  bool failUpdate = false;
  int loadCalls = 0;

  @override
  List<Training> trainingsForUser(int userId) => _cache[userId] ?? const [];

  @override
  AsyncResult<List<Training>> loadForUser(int userId) async {
    loadCalls++;
    if (failLoad) return const Failure(readFailure);
    final snapshot = List<Training>.unmodifiable(stored[userId] ?? const []);
    _cache[userId] = snapshot;
    return Success(snapshot);
  }

  @override
  AsyncResult<Unit> update(Training training) async {
    if (failUpdate) return const Failure(writeFailure);
    final current = [...trainingsForUser(training.userId)];
    final index = current.indexWhere((item) => item.id == training.id);
    if (index >= 0) current[index] = training;
    _cache[training.userId] = List.unmodifiable(current);
    return const Success(unit);
  }

  @override
  AsyncResult<Unit> delete(Training training) async {
    if (training.id == failDeleteId) return const Failure(writeFailure);
    _cache[training.userId] = List.unmodifiable(
      trainingsForUser(training.userId).where(
        (item) => item.id != training.id,
      ),
    );
    return const Success(unit);
  }

  @override
  AsyncResult<Training> insert(Training training) async => Success(training);
}

class _ShareTrainingReportFake implements ShareTrainingReportUseCase {
  int calls = 0;
  User? receivedUser;
  List<Training>? receivedTrainings;
  TrainingReportPdfTexts? receivedTexts;
  String? receivedSubject;
  AsyncResult<Unit> result = Future.value(const Success(unit));
  int preparedCalls = 0;
  TrainingReportContent? receivedContent;

  @override
  AsyncResult<Unit> execute({
    required User user,
    required List<Training> trainings,
    required TrainingReportPdfTexts texts,
    required String subject,
    String suggestedName = 'training_logs.pdf',
  }) {
    calls++;
    receivedUser = user;
    receivedTrainings = List.unmodifiable(trainings);
    receivedTexts = texts;
    receivedSubject = subject;

    return result;
  }

  @override
  AsyncResult<Unit> executeFromContent({
    required TrainingReportContent content,
    required TrainingReportPdfTexts texts,
    required String subject,
    String suggestedName = 'training_logs.pdf',
  }) {
    preparedCalls++;
    receivedContent = content;
    receivedTexts = texts;
    receivedSubject = subject;

    return result;
  }
}

class _SendTrainingReportEmailFake implements SendTrainingReportEmailUseCase {
  int calls = 0;
  User? receivedUser;
  List<Training>? receivedTrainings;
  TrainingReportPdfTexts? receivedTexts;
  List<String>? receivedRecipients;
  String? receivedSubject;
  String? receivedHtmlBody;
  AsyncResult<Unit> result = Future.value(const Success(unit));
  int preparedCalls = 0;
  TrainingReportContent? receivedContent;

  @override
  AsyncResult<Unit> execute({
    required User user,
    required List<Training> trainings,
    required TrainingReportPdfTexts texts,
    required List<String> recipients,
    required String subject,
    required String htmlBody,
    String suggestedName = 'training_logs.pdf',
  }) {
    calls++;
    receivedUser = user;
    receivedTrainings = List.unmodifiable(trainings);
    receivedTexts = texts;
    receivedRecipients = List.unmodifiable(recipients);
    receivedSubject = subject;
    receivedHtmlBody = htmlBody;

    return result;
  }

  @override
  AsyncResult<Unit> executeFromContent({
    required TrainingReportContent content,
    required TrainingReportPdfTexts texts,
    required List<String> recipients,
    required String subject,
    required String htmlBody,
    String suggestedName = 'training_logs.pdf',
  }) {
    preparedCalls++;
    receivedContent = content;
    receivedTexts = texts;
    receivedRecipients = List.unmodifiable(recipients);
    receivedSubject = subject;
    receivedHtmlBody = htmlBody;

    return result;
  }
}

class _BuildTrainingReportFake implements BuildTrainingReportUseCase {
  User? receivedUser;
  List<Training>? receivedTrainings;
  Result<TrainingReportBuildOutcome>? outcome;
  AsyncResult<TrainingReportBuildOutcome>? pendingResult;

  @override
  AsyncResult<TrainingReportContent> execute({
    required User user,
    required List<Training> trainings,
  }) async =>
      Success(
        TrainingReportContent(user: user, sections: const []),
      );

  @override
  AsyncResult<TrainingReportBuildOutcome> buildOutcome({
    required User user,
    required List<Training> trainings,
  }) async {
    receivedUser = user;
    receivedTrainings = List.unmodifiable(trainings);

    final pending = pendingResult;
    if (pending != null) {
      return pending;
    }

    return outcome ??
        Success(
          TrainingReportBuildOutcome(
            content: TrainingReportContent(user: user, sections: const []),
            issues: const [],
          ),
        );
  }
}

void main() {
  late _UserRepositoryFake userRepository;
  late _TrainingRepositoryFake trainingRepository;
  late TrainingsViewModel viewModel;

  late _ShareTrainingReportFake shareTrainingReport;
  late _SendTrainingReportEmailFake sendTrainingReportEmail;
  late _BuildTrainingReportFake buildTrainingReport;

  const ana = User(id: 1, name: 'Ana', email: 'ana@example.com');
  const bia = User(id: 2, name: 'Bia', email: 'bia@example.com');

  const pdfTexts = TrainingReportPdfTexts(
    locale: 'pt_BR',
    reportTitle: 'Relatório',
    userLabel: 'Usuário',
    dateLabel: 'Data',
    totalDistanceLabel: 'Distância total',
    totalTimeLabel: 'Tempo total',
    averageSpeedLabel: 'Velocidade média',
    lapDistanceLabel: 'Distância da volta',
    splitDistanceLabel: 'Distância parcial',
    lapCountLabel: 'Voltas',
    eventColumnLabel: 'Evento',
    timeColumnLabel: 'Tempo',
    speedColumnLabel: 'Velocidade',
    commentsColumnLabel: 'Comentários',
    trainingStartedLabel: 'Treino iniciado',
    splitLabel: 'Parcial',
    lapLabel: 'Volta',
  );

  Training training(int id, int userId, {String? comments}) => Training.create(
        id: id,
        userId: userId,
        date: DateTime(2026, 8, id),
        comments: comments,
      ).value!;

  setUp(() {
    shareTrainingReport = _ShareTrainingReportFake();
    sendTrainingReportEmail = _SendTrainingReportEmailFake();
    buildTrainingReport = _BuildTrainingReportFake();
    userRepository = _UserRepositoryFake()..stored = const [ana, bia];
    trainingRepository = _TrainingRepositoryFake()
      ..stored[1] = [training(11, 1), training(12, 1)]
      ..stored[2] = [training(21, 2)];
    viewModel = TrainingsViewModel(
      userRepository: userRepository,
      trainingRepository: trainingRepository,
      shareTrainingReport: shareTrainingReport,
      sendTrainingReportEmail: sendTrainingReportEmail,
      buildTrainingReport: buildTrainingReport,
    );
    addTearDown(viewModel.dispose);
  });

  test('loads users and exposes command state', () async {
    await viewModel.loadUsers();

    expect(viewModel.loadUsersCommand.isSuccess, isTrue);
    expect(viewModel.users, [ana, bia]);
    expect(viewModel.isLoading, isFalse);
    expect(viewModel.lastError, isNull);
  });

  test('selects a user and loads only that user trainings', () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);

    expect(viewModel.loadTrainingsCommand.isSuccess, isTrue);
    expect(viewModel.selectedUser, ana);
    expect(viewModel.trainings.map((item) => item.id), [11, 12]);
    expect(trainingRepository.loadCalls, 1);
  });

  test('rejects selection of an unavailable user', () async {
    await viewModel.loadUsers();

    await viewModel.selectUser(99);

    expect(viewModel.loadTrainingsCommand.isFailure, isTrue);
    expect(viewModel.lastError?.code, AppErrorCode.invalidData);
    expect(viewModel.selectedUser, isNull);
    expect(trainingRepository.loadCalls, 0);
  });

  test('keeps selection immutable and ignores unavailable trainings', () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);
    final first = viewModel.trainings.first;
    viewModel.setSelected(first, selected: true);
    viewModel.setSelected(training(99, 1), selected: true);

    expect(viewModel.selectedTrainingIds, {11});
    expect(viewModel.selectedTrainings, [first]);
    expect(() => viewModel.selectedTrainingIds.add(12), throwsUnsupportedError);
  });

  test('selects all, clears, and resets selection when user changes', () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);
    viewModel.selectAll();

    expect(viewModel.areAllTrainingsSelected, isTrue);
    expect(viewModel.selectedTrainingIds, {11, 12});

    await viewModel.selectUser(2);

    expect(viewModel.selectedTrainingIds, isEmpty);
    expect(viewModel.trainings.single.id, 21);
    viewModel.selectAll();
    viewModel.clearSelection();
    expect(viewModel.hasSelectedTrainings, isFalse);
  });

  test('reload reconciles selection with the latest repository cache',
      () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);
    viewModel.selectAll();
    trainingRepository.stored[1] = [training(12, 1)];

    await viewModel.reloadTrainings();

    expect(viewModel.trainings.map((item) => item.id), [12]);
    expect(viewModel.selectedTrainingIds, {12});
  });

  test('update and delete reflect repository mutations and selection',
      () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);
    final changed = training(11, 1, comments: 'changed');
    viewModel.setSelected(viewModel.trainings.first, selected: true);

    await viewModel.update(changed);
    await viewModel.delete(changed);

    expect(viewModel.updateCommand.isSuccess, isTrue);
    expect(viewModel.deleteCommand.isSuccess, isTrue);
    expect(viewModel.trainings.map((item) => item.id), [12]);
    expect(viewModel.selectedTrainingIds, isEmpty);
  });

  test('batch deletion reconciles partial success when a later delete fails',
      () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);
    viewModel.selectAll();
    trainingRepository.failDeleteId = 12;

    await viewModel.deleteSelected();

    expect(viewModel.deleteSelectedCommand.isFailure, isTrue);
    expect(viewModel.lastError, writeFailure);
    expect(viewModel.trainings.map((item) => item.id), [12]);
    expect(viewModel.selectedTrainingIds, {12});
  });

  test('failed reload preserves cached trainings and reports AppError',
      () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);
    final cached = viewModel.trainings;
    trainingRepository.failLoad = true;

    await viewModel.reloadTrainings();

    expect(viewModel.loadTrainingsCommand.isFailure, isTrue);
    expect(viewModel.lastError, readFailure);
    expect(viewModel.trainings, same(cached));

    viewModel.clearLastError();
    expect(viewModel.lastError, isNull);
  });

  test('removing the selected user on reload clears page selection', () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);
    viewModel.selectAll();
    userRepository.stored = const [bia];

    await viewModel.loadUsers();

    expect(viewModel.selectedUser, isNull);
    expect(viewModel.trainings, isEmpty);
    expect(viewModel.selectedTrainingIds, isEmpty);
  });

  test('shares a report containing only the selected trainings', () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);

    final selected = viewModel.trainings.first;
    viewModel.setSelected(selected, selected: true);

    await viewModel.shareReport(
      const ShareTrainingReportCommandInput(
        pdfTexts: pdfTexts,
        subject: 'Relatório de treinos',
      ),
    );

    expect(viewModel.shareReportCommand.isSuccess, isTrue);
    expect(viewModel.lastError, isNull);
    expect(shareTrainingReport.calls, 1);
    expect(shareTrainingReport.receivedUser, ana);
    expect(shareTrainingReport.receivedTrainings, [selected]);
    expect(shareTrainingReport.receivedTexts, pdfTexts);
    expect(
      shareTrainingReport.receivedSubject,
      'Relatório de treinos',
    );
  });

  test('rejects report sharing when no training is selected', () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);

    await viewModel.shareReport(
      const ShareTrainingReportCommandInput(
        pdfTexts: pdfTexts,
        subject: 'Relatório de treinos',
      ),
    );

    expect(viewModel.shareReportCommand.isFailure, isTrue);
    expect(viewModel.lastError?.code, AppErrorCode.invalidData);
    expect(shareTrainingReport.calls, 0);
  });

  test('prepares a partial report and deselects only rejected trainings',
      () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);
    viewModel.selectAll();
    final valid = viewModel.trainings.first;
    final rejected = viewModel.trainings.last;
    final issue = TrainingReportIssue(
      training: rejected,
      error: const AppError(
        code: AppErrorCode.invalidData,
        message: 'Training has no measurements.',
      ),
    );
    buildTrainingReport.outcome = Success(
      TrainingReportBuildOutcome(
        content: TrainingReportContent(
          user: ana,
          sections: [
            TrainingReportSection(
              training: valid,
              rows: const [],
              totals: TrainingReportTotals(
                distance: Distance.create(value: 0).value!,
                duration: Duration.zero,
                lapCount: 0,
                averageSpeed: Speed.create(value: 0).value!,
              ),
            ),
          ],
        ),
        issues: [issue],
      ),
    );

    await viewModel.prepareReport();

    expect(viewModel.prepareReportCommand.isSuccess, isTrue);
    expect(buildTrainingReport.receivedUser, ana);
    expect(buildTrainingReport.receivedTrainings, [valid, rejected]);
    expect(viewModel.selectedTrainingIds, {valid.id});
    expect(viewModel.reportIssueFor(rejected), issue);
    expect(
      viewModel.selectionStateFor(valid),
      TrainingSelectionState.selected,
    );
    expect(
      viewModel.selectionStateFor(rejected),
      TrainingSelectionState.rejected,
    );
    expect(viewModel.hasReportIssues, isTrue);
    expect(() => viewModel.reportIssues.clear(), throwsUnsupportedError);
  });

  test('shares prepared content without rebuilding the report', () async {
    final content = TrainingReportContent(
      user: ana,
      sections: const [],
    );

    await viewModel.sharePreparedReport(
      SharePreparedTrainingReportCommandInput(
        content: content,
        pdfTexts: pdfTexts,
        subject: 'Relatório de treinos',
      ),
    );

    expect(viewModel.sharePreparedReportCommand.isSuccess, isTrue);
    expect(shareTrainingReport.preparedCalls, 1);
    expect(shareTrainingReport.calls, 0);
    expect(shareTrainingReport.receivedContent, same(content));
    expect(shareTrainingReport.receivedTexts, pdfTexts);
    expect(
      shareTrainingReport.receivedSubject,
      'Relatório de treinos',
    );
    expect(buildTrainingReport.receivedUser, isNull);
    expect(buildTrainingReport.receivedTrainings, isNull);
  });

  test('emails prepared content without rebuilding the report', () async {
    final content = TrainingReportContent(
      user: ana,
      sections: const [],
    );

    await viewModel.sendPreparedReportEmail(
      EmailPreparedTrainingReportCommandInput(
        content: content,
        pdfTexts: pdfTexts,
        recipients: const ['coach@example.com'],
        subject: 'Relatório de treinos',
        htmlBody: '<p>Relatório em anexo.</p>',
      ),
    );

    expect(viewModel.sendPreparedReportEmailCommand.isSuccess, isTrue);
    expect(sendTrainingReportEmail.preparedCalls, 1);
    expect(sendTrainingReportEmail.calls, 0);
    expect(sendTrainingReportEmail.receivedContent, same(content));
    expect(sendTrainingReportEmail.receivedTexts, pdfTexts);
    expect(
      sendTrainingReportEmail.receivedRecipients,
      ['coach@example.com'],
    );
    expect(
      sendTrainingReportEmail.receivedSubject,
      'Relatório de treinos',
    );
    expect(
      sendTrainingReportEmail.receivedHtmlBody,
      '<p>Relatório em anexo.</p>',
    );
    expect(buildTrainingReport.receivedUser, isNull);
    expect(buildTrainingReport.receivedTrainings, isNull);
  });

  test('reload clears report issues and allows a new validation', () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);

    final rejected = viewModel.trainings.first;
    viewModel.setSelected(rejected, selected: true);

    final issue = TrainingReportIssue(
      training: rejected,
      error: const AppError(
        code: AppErrorCode.invalidData,
        message: 'Training has no measurements.',
      ),
    );

    buildTrainingReport.outcome = Success(
      TrainingReportBuildOutcome(
        content: TrainingReportContent(
          user: ana,
          sections: const [],
        ),
        issues: [issue],
      ),
    );

    await viewModel.prepareReport();

    expect(viewModel.reportIssueFor(rejected), issue);
    expect(
      viewModel.selectionStateFor(rejected),
      TrainingSelectionState.rejected,
    );
    expect(viewModel.selectedTrainingIds, isEmpty);

    await viewModel.reloadTrainings();

    final reloaded = viewModel.trainings.first;

    expect(viewModel.reportIssueFor(reloaded), isNull);
    expect(viewModel.hasReportIssues, isFalse);
    expect(
      viewModel.selectionStateFor(reloaded),
      TrainingSelectionState.unselected,
    );

    viewModel.setSelected(reloaded, selected: true);

    expect(
      viewModel.selectionStateFor(reloaded),
      TrainingSelectionState.selected,
    );
  });

  test('successful update clears the report issue for that training', () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);

    final rejected = viewModel.trainings.first;
    viewModel.setSelected(rejected, selected: true);

    final issue = TrainingReportIssue(
      training: rejected,
      error: const AppError(
        code: AppErrorCode.invalidData,
        message: 'Training has no measurements.',
      ),
    );

    buildTrainingReport.outcome = Success(
      TrainingReportBuildOutcome(
        content: TrainingReportContent(
          user: ana,
          sections: const [],
        ),
        issues: [issue],
      ),
    );

    await viewModel.prepareReport();

    expect(viewModel.reportIssueFor(rejected), issue);

    final updated = training(
      rejected.id!,
      rejected.userId,
      comments: 'Histórico corrigido',
    );

    await viewModel.update(updated);

    expect(viewModel.updateCommand.isSuccess, isTrue);
    expect(viewModel.reportIssueFor(updated), isNull);
    expect(viewModel.hasReportIssues, isFalse);
    expect(
      viewModel.selectionStateFor(updated),
      TrainingSelectionState.unselected,
    );
  });

  test('failed update preserves the report issue', () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);

    final rejected = viewModel.trainings.first;
    viewModel.setSelected(rejected, selected: true);

    final issue = TrainingReportIssue(
      training: rejected,
      error: const AppError(
        code: AppErrorCode.invalidData,
        message: 'Training has no measurements.',
      ),
    );

    buildTrainingReport.outcome = Success(
      TrainingReportBuildOutcome(
        content: TrainingReportContent(
          user: ana,
          sections: const [],
        ),
        issues: [issue],
      ),
    );

    await viewModel.prepareReport();

    expect(viewModel.reportIssueFor(rejected), issue);

    trainingRepository.failUpdate = true;

    final changed = training(
      rejected.id!,
      rejected.userId,
      comments: 'Alteração não persistida',
    );

    await viewModel.update(changed);

    expect(viewModel.updateCommand.isFailure, isTrue);
    expect(viewModel.lastError, writeFailure);
    expect(viewModel.reportIssueFor(rejected), issue);
    expect(viewModel.hasReportIssues, isTrue);
    expect(
      viewModel.selectionStateFor(rejected),
      TrainingSelectionState.rejected,
    );
  });

  test('successful deletion removes the training report issue', () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);

    final rejected = viewModel.trainings.first;
    viewModel.setSelected(rejected, selected: true);

    final issue = TrainingReportIssue(
      training: rejected,
      error: const AppError(
        code: AppErrorCode.invalidData,
        message: 'Training has no measurements.',
      ),
    );

    buildTrainingReport.outcome = Success(
      TrainingReportBuildOutcome(
        content: TrainingReportContent(
          user: ana,
          sections: const [],
        ),
        issues: [issue],
      ),
    );

    await viewModel.prepareReport();

    expect(viewModel.reportIssueFor(rejected), issue);

    await viewModel.delete(rejected);

    expect(viewModel.deleteCommand.isSuccess, isTrue);
    expect(viewModel.trainings.map((item) => item.id),
        isNot(contains(rejected.id)));
    expect(viewModel.reportIssueFor(rejected), isNull);
    expect(viewModel.hasReportIssues, isFalse);
  });

  test('changing the selected user clears previous report issues', () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);

    final rejected = viewModel.trainings.first;
    viewModel.setSelected(rejected, selected: true);

    final issue = TrainingReportIssue(
      training: rejected,
      error: const AppError(
        code: AppErrorCode.invalidData,
        message: 'Training has no measurements.',
      ),
    );

    buildTrainingReport.outcome = Success(
      TrainingReportBuildOutcome(
        content: TrainingReportContent(
          user: ana,
          sections: const [],
        ),
        issues: [issue],
      ),
    );

    await viewModel.prepareReport();

    expect(viewModel.reportIssueFor(rejected), issue);
    expect(viewModel.hasReportIssues, isTrue);

    await viewModel.selectUser(2);

    expect(viewModel.selectedUser, bia);
    expect(viewModel.trainings.single.id, 21);
    expect(viewModel.selectedTrainingIds, isEmpty);
    expect(viewModel.hasReportIssues, isFalse);
    expect(viewModel.reportIssues, isEmpty);
  });

  test('rejects prepared email while prepared sharing is running', () async {
    final content = TrainingReportContent(
      user: ana,
      sections: const [],
    );

    final shareCompleter = Completer<Result<Unit>>();
    shareTrainingReport.result = shareCompleter.future;

    final sharing = viewModel.sharePreparedReport(
      SharePreparedTrainingReportCommandInput(
        content: content,
        pdfTexts: pdfTexts,
        subject: 'Relatório de treinos',
      ),
    );

    expect(viewModel.sharePreparedReportCommand.isRunning, isTrue);
    expect(viewModel.isReportOperationRunning, isTrue);

    await viewModel.sendPreparedReportEmail(
      EmailPreparedTrainingReportCommandInput(
        content: content,
        pdfTexts: pdfTexts,
        recipients: const ['coach@example.com'],
        subject: 'Relatório de treinos',
        htmlBody: '<p>Relatório em anexo.</p>',
      ),
    );

    expect(viewModel.sendPreparedReportEmailCommand.isFailure, isTrue);
    expect(
      viewModel.sendPreparedReportEmailCommand.error?.code,
      AppErrorCode.invalidData,
    );
    expect(sendTrainingReportEmail.preparedCalls, 0);

    shareCompleter.complete(const Success(unit));
    await sharing;

    expect(viewModel.sharePreparedReportCommand.isSuccess, isTrue);
    expect(viewModel.isReportOperationRunning, isFalse);
  });

  test('rejects report preparation while prepared sharing is running',
      () async {
    final content = TrainingReportContent(
      user: ana,
      sections: const [],
    );

    final shareCompleter = Completer<Result<Unit>>();
    shareTrainingReport.result = shareCompleter.future;

    final sharing = viewModel.sharePreparedReport(
      SharePreparedTrainingReportCommandInput(
        content: content,
        pdfTexts: pdfTexts,
        subject: 'Relatório de treinos',
      ),
    );

    expect(viewModel.sharePreparedReportCommand.isRunning, isTrue);

    await viewModel.prepareReport();

    expect(viewModel.prepareReportCommand.isFailure, isTrue);
    expect(
      viewModel.prepareReportCommand.error?.code,
      AppErrorCode.invalidData,
    );
    expect(buildTrainingReport.receivedUser, isNull);
    expect(buildTrainingReport.receivedTrainings, isNull);

    shareCompleter.complete(const Success(unit));
    await sharing;

    expect(viewModel.sharePreparedReportCommand.isSuccess, isTrue);
    expect(viewModel.isReportOperationRunning, isFalse);
  });

  test('rejects prepared sharing while report preparation is running',
      () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);

    final selected = viewModel.trainings.first;
    viewModel.setSelected(selected, selected: true);

    final prepareCompleter = Completer<Result<TrainingReportBuildOutcome>>();
    buildTrainingReport.pendingResult = prepareCompleter.future;

    final preparing = viewModel.prepareReport();

    expect(viewModel.prepareReportCommand.isRunning, isTrue);
    expect(viewModel.isReportOperationRunning, isTrue);

    final content = TrainingReportContent(
      user: ana,
      sections: const [],
    );

    await viewModel.sharePreparedReport(
      SharePreparedTrainingReportCommandInput(
        content: content,
        pdfTexts: pdfTexts,
        subject: 'Relatório de treinos',
      ),
    );

    expect(viewModel.sharePreparedReportCommand.isFailure, isTrue);
    expect(
      viewModel.sharePreparedReportCommand.error?.code,
      AppErrorCode.invalidData,
    );
    expect(shareTrainingReport.preparedCalls, 0);

    prepareCompleter.complete(
      Success(
        TrainingReportBuildOutcome(
          content: content,
          issues: const [],
        ),
      ),
    );
    await preparing;

    expect(viewModel.prepareReportCommand.isSuccess, isTrue);
    expect(viewModel.isReportOperationRunning, isFalse);
  });

  test('global preparation failure preserves selection and report issues',
      () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);
    viewModel.selectAll();

    final selectedBefore = viewModel.selectedTrainingIds.toSet();

    buildTrainingReport.outcome = const Failure(reportFailure);

    await viewModel.prepareReport();

    expect(viewModel.prepareReportCommand.isFailure, isTrue);
    expect(viewModel.prepareReportCommand.error, reportFailure);
    expect(viewModel.lastError, reportFailure);
    expect(viewModel.selectedTrainingIds, selectedBefore);
    expect(viewModel.hasReportIssues, isFalse);
    expect(viewModel.reportIssues, isEmpty);
  });

  test('fully rejected preparation deselects every invalid training', () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);
    viewModel.selectAll();

    final first = viewModel.trainings.first;
    final second = viewModel.trainings.last;

    final firstIssue = TrainingReportIssue(
      training: first,
      error: const AppError(
        code: AppErrorCode.invalidData,
        message: 'Training has no measurements.',
      ),
    );

    final secondIssue = TrainingReportIssue(
      training: second,
      error: const AppError(
        code: AppErrorCode.invalidData,
        message: 'Training history is inconsistent.',
      ),
    );

    buildTrainingReport.outcome = Success(
      TrainingReportBuildOutcome(
        content: TrainingReportContent(
          user: ana,
          sections: const [],
        ),
        issues: [firstIssue, secondIssue],
      ),
    );

    await viewModel.prepareReport();

    final outcome = viewModel.prepareReportCommand.value!;

    expect(viewModel.prepareReportCommand.isSuccess, isTrue);
    expect(outcome.status, TrainingReportBuildStatus.rejected);
    expect(outcome.hasContent, isFalse);
    expect(outcome.issues, [firstIssue, secondIssue]);

    expect(viewModel.selectedTrainingIds, isEmpty);
    expect(viewModel.reportIssueFor(first), firstIssue);
    expect(viewModel.reportIssueFor(second), secondIssue);
    expect(
      viewModel.selectionStateFor(first),
      TrainingSelectionState.rejected,
    );
    expect(
      viewModel.selectionStateFor(second),
      TrainingSelectionState.rejected,
    );

    expect(shareTrainingReport.calls, 0);
    expect(shareTrainingReport.preparedCalls, 0);
    expect(sendTrainingReportEmail.calls, 0);
    expect(sendTrainingReportEmail.preparedCalls, 0);
  });

  test('emails a report containing only the selected trainings', () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);

    final selected = viewModel.trainings.last;
    viewModel.setSelected(selected, selected: true);

    await viewModel.sendReportEmail(
      EmailTrainingReportCommandInput(
        pdfTexts: pdfTexts,
        recipients: const ['coach@example.com'],
        subject: 'Relatório de treinos',
        htmlBody: '<p>Relatório em anexo.</p>',
      ),
    );

    expect(viewModel.sendReportEmailCommand.isSuccess, isTrue);
    expect(viewModel.lastError, isNull);
    expect(sendTrainingReportEmail.calls, 1);
    expect(sendTrainingReportEmail.receivedUser, ana);
    expect(sendTrainingReportEmail.receivedTrainings, [selected]);
    expect(sendTrainingReportEmail.receivedTexts, pdfTexts);
    expect(
      sendTrainingReportEmail.receivedRecipients,
      ['coach@example.com'],
    );
    expect(
      sendTrainingReportEmail.receivedSubject,
      'Relatório de treinos',
    );
    expect(
      sendTrainingReportEmail.receivedHtmlBody,
      '<p>Relatório em anexo.</p>',
    );
  });

  test('rejects report email when no training is selected', () async {
    await viewModel.loadUsers();
    await viewModel.selectUser(1);

    await viewModel.sendReportEmail(
      EmailTrainingReportCommandInput(
        pdfTexts: pdfTexts,
        recipients: const ['coach@example.com'],
        subject: 'Relatório de treinos',
        htmlBody: '<p>Relatório em anexo.</p>',
      ),
    );

    expect(viewModel.sendReportEmailCommand.isFailure, isTrue);
    expect(viewModel.lastError?.code, AppErrorCode.invalidData);
    expect(sendTrainingReportEmail.calls, 0);
  });

  test('exposes sharing failures through the command and lastError', () async {
    shareTrainingReport.result = Future.value(
      const Failure(reportFailure),
    );

    await viewModel.loadUsers();
    await viewModel.selectUser(1);
    viewModel.setSelected(viewModel.trainings.first, selected: true);

    await viewModel.shareReport(
      const ShareTrainingReportCommandInput(
        pdfTexts: pdfTexts,
        subject: 'Relatório de treinos',
      ),
    );

    expect(viewModel.shareReportCommand.isFailure, isTrue);
    expect(viewModel.shareReportCommand.error, reportFailure);
    expect(viewModel.lastError, reportFailure);
    expect(shareTrainingReport.calls, 1);
  });

  test('exposes email failures through the command and lastError', () async {
    sendTrainingReportEmail.result = Future.value(
      const Failure(reportFailure),
    );

    await viewModel.loadUsers();
    await viewModel.selectUser(1);
    viewModel.setSelected(viewModel.trainings.first, selected: true);

    await viewModel.sendReportEmail(
      EmailTrainingReportCommandInput(
        pdfTexts: pdfTexts,
        recipients: const ['coach@example.com'],
        subject: 'Relatório de treinos',
        htmlBody: '<p>Relatório em anexo.</p>',
      ),
    );

    expect(viewModel.sendReportEmailCommand.isFailure, isTrue);
    expect(viewModel.sendReportEmailCommand.error, reportFailure);
    expect(viewModel.lastError, reportFailure);
    expect(sendTrainingReportEmail.calls, 1);
  });

  test('rejects email while report sharing is running', () async {
    final shareCompleter = Completer<Result<Unit>>();
    shareTrainingReport.result = shareCompleter.future;

    await viewModel.loadUsers();
    await viewModel.selectUser(1);
    viewModel.setSelected(viewModel.trainings.first, selected: true);

    final sharing = viewModel.shareReport(
      const ShareTrainingReportCommandInput(
        pdfTexts: pdfTexts,
        subject: 'Relatório de treinos',
      ),
    );

    expect(viewModel.shareReportCommand.isRunning, isTrue);
    expect(viewModel.isReportOperationRunning, isTrue);

    await viewModel.sendReportEmail(
      EmailTrainingReportCommandInput(
        pdfTexts: pdfTexts,
        recipients: const ['coach@example.com'],
        subject: 'Relatório de treinos',
        htmlBody: '<p>Relatório em anexo.</p>',
      ),
    );

    expect(viewModel.sendReportEmailCommand.isFailure, isTrue);
    expect(
        viewModel.sendReportEmailCommand.error?.code, AppErrorCode.invalidData);
    expect(sendTrainingReportEmail.calls, 0);

    shareCompleter.complete(const Success(unit));
    await sharing;

    expect(viewModel.shareReportCommand.isSuccess, isTrue);
    expect(viewModel.isReportOperationRunning, isFalse);
  });

  test('rejects sharing while report email is running', () async {
    final emailCompleter = Completer<Result<Unit>>();
    sendTrainingReportEmail.result = emailCompleter.future;

    await viewModel.loadUsers();
    await viewModel.selectUser(1);
    viewModel.setSelected(viewModel.trainings.first, selected: true);

    final sending = viewModel.sendReportEmail(
      EmailTrainingReportCommandInput(
        pdfTexts: pdfTexts,
        recipients: const ['coach@example.com'],
        subject: 'Relatório de treinos',
        htmlBody: '<p>Relatório em anexo.</p>',
      ),
    );

    expect(viewModel.sendReportEmailCommand.isRunning, isTrue);
    expect(viewModel.isReportOperationRunning, isTrue);

    await viewModel.shareReport(
      const ShareTrainingReportCommandInput(
        pdfTexts: pdfTexts,
        subject: 'Relatório de treinos',
      ),
    );

    expect(viewModel.shareReportCommand.isFailure, isTrue);
    expect(viewModel.shareReportCommand.error?.code, AppErrorCode.invalidData);
    expect(shareTrainingReport.calls, 0);

    emailCompleter.complete(const Success(unit));
    await sending;

    expect(viewModel.sendReportEmailCommand.isSuccess, isTrue);
    expect(viewModel.isReportOperationRunning, isFalse);
  });
}
