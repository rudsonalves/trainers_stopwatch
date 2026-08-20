import 'dart:collection';

import 'package:flutter/foundation.dart';

import '/core/result/command.dart';
import '/data/repositories/trainings/training_repository.dart';
import '/data/repositories/users/user_repository.dart';
import '/domain/common/training/models/training.dart';
import '/domain/common/user/models/user.dart';

class TrainingsViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final TrainingRepository _trainingRepository;
  final Set<int> _selectedTrainingIds = {};
  final Map<Command<Object>, VoidCallback> _commandListeners = {};

  late final Command0<List<User>> loadUsersCommand;
  late final Command1<List<Training>, int> loadTrainingsCommand;
  late final Command1<Unit, Training> updateCommand;
  late final Command1<Unit, Training> deleteCommand;
  late final Command0<Unit> deleteSelectedCommand;

  User? _selectedUser;
  AppError? _lastError;

  TrainingsViewModel({
    required UserRepository userRepository,
    required TrainingRepository trainingRepository,
  })  : _userRepository = userRepository,
        _trainingRepository = trainingRepository {
    loadUsersCommand = Command0<List<User>>(_loadUsers);
    loadTrainingsCommand = Command1<List<Training>, int>(_loadTrainings);
    updateCommand = Command1<Unit, Training>(_update);
    deleteCommand = Command1<Unit, Training>(_delete);
    deleteSelectedCommand = Command0<Unit>(_deleteSelected);

    for (final command in _commands) {
      void listener() => _onCommandChanged(command);
      _commandListeners[command] = listener;
      command.addListener(listener);
    }
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
      ];

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
}
