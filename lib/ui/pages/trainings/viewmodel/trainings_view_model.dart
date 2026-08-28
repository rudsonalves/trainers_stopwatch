import 'dart:collection';

import 'package:flutter/foundation.dart';

import '/core/result/command.dart';
import '/data/repositories/trainings/training_repository.dart';
import '/data/repositories/users/user_repository.dart';
import '/domain/common/report/models/training_report_build_outcome.dart';
import '/domain/common/report/models/training_report_issue.dart';
import '/domain/common/training/models/training.dart';
import '/domain/common/user/models/user.dart';
import '/domain/usecases/reports/build_training_report_use_case.dart';
import '/domain/usecases/reports/send_training_report_email_use_case.dart';
import '/domain/usecases/reports/share_training_report_use_case.dart';
import 'models/email_prepared_training_report_command_input.dart';
import 'models/share_prepared_training_report_command_input.dart';
import 'models/training_selection_state.dart';

class TrainingsViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final TrainingRepository _trainingRepository;
  final ShareTrainingReportUseCase _shareTrainingReport;
  final SendTrainingReportEmailUseCase _sendTrainingReportEmail;
  final Set<int> _selectedTrainingIds = {};
  final Map<Command<Object>, VoidCallback> _commandListeners = {};
  final BuildTrainingReportUseCase _buildTrainingReport;

  TrainingsViewModel({
    required UserRepository userRepository,
    required TrainingRepository trainingRepository,
    required ShareTrainingReportUseCase shareTrainingReport,
    required SendTrainingReportEmailUseCase sendTrainingReportEmail,
    required BuildTrainingReportUseCase buildTrainingReport,
  })  : _userRepository = userRepository,
        _trainingRepository = trainingRepository,
        _shareTrainingReport = shareTrainingReport,
        _sendTrainingReportEmail = sendTrainingReportEmail,
        _buildTrainingReport = buildTrainingReport {
    loadUsersCommand = Command0<List<User>>(_loadUsers);
    loadTrainingsCommand = Command1<List<Training>, int>(_loadTrainings);
    updateCommand = Command1<Unit, Training>(_update);
    deleteCommand = Command1<Unit, Training>(_delete);
    deleteSelectedCommand = Command0<Unit>(_deleteSelected);
    sharePreparedReportCommand =
        Command1<Unit, SharePreparedTrainingReportCommandInput>(
      _sharePreparedReport,
    );

    sendPreparedReportEmailCommand =
        Command1<Unit, EmailPreparedTrainingReportCommandInput>(
      _sendPreparedReportEmail,
    );
    prepareReportCommand = Command0<TrainingReportBuildOutcome>(_prepareReport);

    for (final command in _commands) {
      void listener() => _onCommandChanged(command);
      _commandListeners[command] = listener;
      command.addListener(listener);
    }
  }

  late final Command0<List<User>> loadUsersCommand;
  late final Command1<List<Training>, int> loadTrainingsCommand;
  late final Command1<Unit, Training> updateCommand;
  late final Command1<Unit, Training> deleteCommand;
  late final Command0<Unit> deleteSelectedCommand;
  late final Command1<Unit, SharePreparedTrainingReportCommandInput>
      sharePreparedReportCommand;

  late final Command1<Unit, EmailPreparedTrainingReportCommandInput>
      sendPreparedReportEmailCommand;
  late final Command0<TrainingReportBuildOutcome> prepareReportCommand;

  User? _selectedUser;
  AppError? _lastError;
  final Map<int, TrainingReportIssue> _reportIssuesByTrainingId = {};

  Map<int, TrainingReportIssue> get reportIssues =>
      UnmodifiableMapView(_reportIssuesByTrainingId);

  bool get hasReportIssues => _reportIssuesByTrainingId.isNotEmpty;

  bool get isReportOperationRunning =>
      prepareReportCommand.isRunning ||
      sharePreparedReportCommand.isRunning ||
      sendPreparedReportEmailCommand.isRunning;

  TrainingReportIssue? reportIssueFor(Training training) {
    final id = training.id;
    return id == null ? null : _reportIssuesByTrainingId[id];
  }

  TrainingSelectionState selectionStateFor(Training training) {
    if (reportIssueFor(training) != null) {
      return TrainingSelectionState.rejected;
    }

    return isSelected(training)
        ? TrainingSelectionState.selected
        : TrainingSelectionState.unselected;
  }

  @override
  void dispose() {
    for (final command in _commands) {
      command
        ..removeListener(_commandListeners[command]!)
        ..dispose();
    }
    _commandListeners.clear();
    super.dispose();
  }

  List<User> get users => _userRepository.users;

  User? get selectedUser => _selectedUser;

  int? get selectedUserId => _selectedUser?.id;

  List<Training> get trainings {
    final userId = selectedUserId;
    return userId == null
        ? const []
        : _trainingRepository.trainingsForUser(userId);
  }

  Set<int> get selectedTrainingIds => UnmodifiableSetView(_selectedTrainingIds);

  List<Training> get selectedTrainings => List.unmodifiable(
        trainings.where((training) {
          final id = training.id;
          return id != null && _selectedTrainingIds.contains(id);
        }),
      );

  bool get hasSelectedTrainings => _selectedTrainingIds.isNotEmpty;

  bool get areAllTrainingsSelected =>
      trainings.isNotEmpty && selectedTrainings.length == trainings.length;

  AppError? get lastError => _lastError;

  bool get isLoading => _commands.any((command) => command.isRunning);

  AppError get _concurrentReportOperationError => const AppError(
        code: AppErrorCode.invalidData,
        message: 'Another report operation is already running.',
      );

  Iterable<Command<Object>> get _commands => [
        loadUsersCommand,
        loadTrainingsCommand,
        updateCommand,
        deleteCommand,
        deleteSelectedCommand,
        sharePreparedReportCommand,
        sendPreparedReportEmailCommand,
        prepareReportCommand,
      ];

  Future<void> sharePreparedReport(
    SharePreparedTrainingReportCommandInput input,
  ) =>
      sharePreparedReportCommand.execute(input);

  Future<void> sendPreparedReportEmail(
    EmailPreparedTrainingReportCommandInput input,
  ) =>
      sendPreparedReportEmailCommand.execute(input);

  Future<void> prepareReport() => prepareReportCommand.execute();

  Future<void> loadUsers() => loadUsersCommand.execute();

  Future<void> selectUser(int userId) => loadTrainingsCommand.execute(userId);

  Future<void> reloadTrainings() async {
    final userId = selectedUserId;
    if (userId == null) {
      await loadTrainingsCommand.execute(-1);
      return;
    }
    await loadTrainingsCommand.execute(userId);
  }

  Future<void> update(Training training) => updateCommand.execute(training);

  Future<void> delete(Training training) => deleteCommand.execute(training);

  Future<void> deleteSelected() => deleteSelectedCommand.execute();

  bool isSelected(Training training) {
    final id = training.id;
    return id != null && _selectedTrainingIds.contains(id);
  }

  void setSelected(Training training, {required bool selected}) {
    final id = training.id;
    if (id == null || !trainings.any((item) => item.id == id)) return;

    final changed = selected
        ? _selectedTrainingIds.add(id)
        : _selectedTrainingIds.remove(id);
    if (changed) notifyListeners();
  }

  void selectAll() {
    final ids = trainings.map((training) => training.id).nonNulls;
    final before = _selectedTrainingIds.length;
    _selectedTrainingIds.addAll(ids);
    if (_selectedTrainingIds.length != before) notifyListeners();
  }

  void clearSelection() {
    if (_selectedTrainingIds.isEmpty) return;
    _selectedTrainingIds.clear();
    notifyListeners();
  }

  void clearLastError() {
    if (_lastError == null) return;
    _lastError = null;
    notifyListeners();
  }

  AsyncResult<TrainingReportBuildOutcome> _prepareReport() async {
    if (sharePreparedReportCommand.isRunning ||
        sendPreparedReportEmailCommand.isRunning) {
      return Failure(_concurrentReportOperationError);
    }

    final reportData = _selectedReportData();
    if (reportData.isFailure) {
      return Failure(reportData.error!);
    }

    final data = reportData.value!;
    final result = await _buildTrainingReport.buildOutcome(
      user: data.user,
      trainings: data.trainings,
    );

    if (result.isFailure) {
      return Failure(result.error!);
    }

    final outcome = result.value!;
    _applyReportOutcome(outcome);

    return Success(outcome);
  }

  AsyncResult<List<User>> _loadUsers() async {
    final result = await _userRepository.loadAll();
    if (result.isFailure) return Failure(result.error!);

    final selectedId = selectedUserId;
    if (selectedId != null && !users.any((user) => user.id == selectedId)) {
      _selectedUser = null;
      _selectedTrainingIds.clear();
      _reportIssuesByTrainingId.clear();
    }
    return Success(result.value!);
  }

  AsyncResult<List<Training>> _loadTrainings(int userId) async {
    final user = users.where((candidate) => candidate.id == userId).firstOrNull;
    if (user == null) {
      return Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'A persisted user is required to load trainings.',
          details: userId,
        ),
      );
    }

    if (selectedUserId != userId) _selectedTrainingIds.clear();
    _selectedUser = user;

    final result = await _trainingRepository.loadForUser(userId);
    if (result.isFailure) return Failure(result.error!);

    _reportIssuesByTrainingId.clear();
    _reconcileSelection();

    return Success(result.value!);
  }

  AsyncResult<Unit> _update(Training training) async {
    final result = await _trainingRepository.update(training);
    if (result.isFailure) {
      return Failure(result.error!);
    }

    _clearReportIssue(training);
    return const Success(unit);
  }

  AsyncResult<Unit> _delete(Training training) async {
    final result = await _trainingRepository.delete(training);
    if (result.isFailure) return Failure(result.error!);

    final id = training.id;
    if (id != null) {
      _selectedTrainingIds.remove(id);
      _reportIssuesByTrainingId.remove(id);
    }

    _reconcileSelection();
    return const Success(unit);
  }

  AsyncResult<Unit> _deleteSelected() async {
    final pending = selectedTrainings.toList(growable: false);
    for (final training in pending) {
      final result = await _trainingRepository.delete(training);
      if (result.isFailure) {
        _reconcileSelection();
        return Failure(result.error!);
      }
      final id = training.id;
      if (id != null) {
        _selectedTrainingIds.remove(id);
        _reportIssuesByTrainingId.remove(id);
      }
    }
    _reconcileSelection();
    return const Success(unit);
  }

  Result<({User user, List<Training> trainings})> _selectedReportData() {
    final user = selectedUser;
    if (user == null) {
      return const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'A user must be selected before generating a report.',
        ),
      );
    }

    final selected = selectedTrainings;
    if (selected.isEmpty) {
      return const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'At least one training must be selected.',
        ),
      );
    }

    return Success((
      user: user,
      trainings: selected,
    ));
  }

  AsyncResult<Unit> _sharePreparedReport(
    SharePreparedTrainingReportCommandInput input,
  ) {
    if (prepareReportCommand.isRunning ||
        sendPreparedReportEmailCommand.isRunning) {
      return Future.value(
        Failure(_concurrentReportOperationError),
      );
    }

    return _shareTrainingReport.executeFromContent(
      content: input.content,
      texts: input.pdfTexts,
      subject: input.subject,
    );
  }

  AsyncResult<Unit> _sendPreparedReportEmail(
    EmailPreparedTrainingReportCommandInput input,
  ) {
    if (prepareReportCommand.isRunning ||
        sharePreparedReportCommand.isRunning) {
      return Future.value(
        Failure(_concurrentReportOperationError),
      );
    }

    return _sendTrainingReportEmail.executeFromContent(
      content: input.content,
      texts: input.pdfTexts,
      recipients: input.recipients,
      subject: input.subject,
      htmlBody: input.htmlBody,
    );
  }

  void _reconcileSelection() {
    final availableIds = trainings.map((training) => training.id).nonNulls;
    _selectedTrainingIds.retainAll(availableIds);
  }

  void _clearReportIssue(Training training) {
    final id = training.id;
    if (id != null) {
      _reportIssuesByTrainingId.remove(id);
    }
  }

  void _onCommandChanged(Command<Object> command) {
    if (command.isRunning || command.isSuccess) {
      _lastError = null;
    } else if (command.isFailure) {
      _lastError = command.error;
    }
    notifyListeners();
  }

  void _applyReportOutcome(TrainingReportBuildOutcome outcome) {
    for (final section in outcome.content.sections) {
      final id = section.training.id;
      if (id != null) {
        _reportIssuesByTrainingId.remove(id);
      }
    }

    for (final issue in outcome.issues) {
      final id = issue.training.id;
      if (id == null) continue;

      _reportIssuesByTrainingId[id] = issue;
      _selectedTrainingIds.remove(id);
    }

    notifyListeners();
  }
}
