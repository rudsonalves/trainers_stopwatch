import 'dart:collection';

import 'package:flutter/foundation.dart';

import '/core/result/command.dart';
import '/data/repositories/trainings/training_repository.dart';
import '/data/repositories/users/user_repository.dart';
import '/domain/common/training/models/training.dart';
import '/domain/common/user/models/user.dart';
import '/domain/usecases/reports/send_training_report_email_use_case.dart';
import '/domain/usecases/reports/share_training_report_use_case.dart';
import 'models/training_report_command_inputs.dart';

class TrainingsViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final TrainingRepository _trainingRepository;
  final ShareTrainingReportUseCase _shareTrainingReport;
  final SendTrainingReportEmailUseCase _sendTrainingReportEmail;
  final Set<int> _selectedTrainingIds = {};
  final Map<Command<Object>, VoidCallback> _commandListeners = {};

  late final Command0<List<User>> loadUsersCommand;
  late final Command1<List<Training>, int> loadTrainingsCommand;
  late final Command1<Unit, Training> updateCommand;
  late final Command1<Unit, Training> deleteCommand;
  late final Command0<Unit> deleteSelectedCommand;
  late final Command1<Unit, ShareTrainingReportCommandInput> shareReportCommand;
  late final Command1<Unit, EmailTrainingReportCommandInput>
      sendReportEmailCommand;

  User? _selectedUser;
  AppError? _lastError;

  TrainingsViewModel({
    required UserRepository userRepository,
    required TrainingRepository trainingRepository,
    required ShareTrainingReportUseCase shareTrainingReport,
    required SendTrainingReportEmailUseCase sendTrainingReportEmail,
  })  : _userRepository = userRepository,
        _trainingRepository = trainingRepository,
        _shareTrainingReport = shareTrainingReport,
        _sendTrainingReportEmail = sendTrainingReportEmail {
    loadUsersCommand = Command0<List<User>>(_loadUsers);
    loadTrainingsCommand = Command1<List<Training>, int>(_loadTrainings);
    updateCommand = Command1<Unit, Training>(_update);
    deleteCommand = Command1<Unit, Training>(_delete);
    deleteSelectedCommand = Command0<Unit>(_deleteSelected);
    shareReportCommand =
        Command1<Unit, ShareTrainingReportCommandInput>(_shareReport);
    sendReportEmailCommand =
        Command1<Unit, EmailTrainingReportCommandInput>(_sendReportEmail);

    for (final command in _commands) {
      void listener() => _onCommandChanged(command);
      _commandListeners[command] = listener;
      command.addListener(listener);
    }
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

  Iterable<Command<Object>> get _commands => [
        loadUsersCommand,
        loadTrainingsCommand,
        updateCommand,
        deleteCommand,
        deleteSelectedCommand,
        shareReportCommand,
        sendReportEmailCommand,
      ];

  bool get isReportOperationRunning =>
      shareReportCommand.isRunning || sendReportEmailCommand.isRunning;

  Future<void> shareReport(
    ShareTrainingReportCommandInput input,
  ) =>
      shareReportCommand.execute(input);

  Future<void> sendReportEmail(
    EmailTrainingReportCommandInput input,
  ) =>
      sendReportEmailCommand.execute(input);

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

  AsyncResult<List<User>> _loadUsers() async {
    final result = await _userRepository.loadAll();
    if (result.isFailure) return Failure(result.error!);

    final selectedId = selectedUserId;
    if (selectedId != null && !users.any((user) => user.id == selectedId)) {
      _selectedUser = null;
      _selectedTrainingIds.clear();
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
    _reconcileSelection();
    return Success(result.value!);
  }

  AsyncResult<Unit> _update(Training training) =>
      _trainingRepository.update(training);

  AsyncResult<Unit> _delete(Training training) async {
    final result = await _trainingRepository.delete(training);
    if (result.isFailure) return Failure(result.error!);
    final id = training.id;
    if (id != null) _selectedTrainingIds.remove(id);
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
      if (id != null) _selectedTrainingIds.remove(id);
    }
    _reconcileSelection();
    return const Success(unit);
  }

  AsyncResult<Unit> _shareReport(
    ShareTrainingReportCommandInput input,
  ) {
    if (sendReportEmailCommand.isRunning) {
      return Future.value(Failure(_concurrentReportOperationError));
    }

    final reportData = _selectedReportData();
    if (reportData.isFailure) {
      return Future.value(Failure(reportData.error!));
    }

    final data = reportData.value!;

    return _shareTrainingReport.execute(
      user: data.user,
      trainings: data.trainings,
      texts: input.pdfTexts,
      subject: input.subject,
    );
  }

  AsyncResult<Unit> _sendReportEmail(
    EmailTrainingReportCommandInput input,
  ) {
    if (shareReportCommand.isRunning) {
      return Future.value(Failure(_concurrentReportOperationError));
    }

    final reportData = _selectedReportData();
    if (reportData.isFailure) {
      return Future.value(Failure(reportData.error!));
    }

    final data = reportData.value!;

    return _sendTrainingReportEmail.execute(
      user: data.user,
      trainings: data.trainings,
      texts: input.pdfTexts,
      recipients: input.recipients,
      subject: input.subject,
      htmlBody: input.htmlBody,
    );
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

  AppError get _concurrentReportOperationError => const AppError(
        code: AppErrorCode.invalidData,
        message: 'Another report operation is already running.',
      );

  void _reconcileSelection() {
    final availableIds = trainings.map((training) => training.id).nonNulls;
    _selectedTrainingIds.retainAll(availableIds);
  }

  void _onCommandChanged(Command<Object> command) {
    if (command.isRunning || command.isSuccess) {
      _lastError = null;
    } else if (command.isFailure) {
      _lastError = command.error;
    }
    notifyListeners();
  }
}
