import 'package:flutter/foundation.dart';

import '/core/result/command.dart';
import '/data/repositories/histories/history_repository.dart';
import '/domain/common/history/models/history_entry.dart';
import '/domain/common/training/events/training_event.dart';
import '/domain/common/training/models/training.dart';
import '/domain/common/training/services/training_event_generator.dart';
import 'models/history_comment_update.dart';
import 'models/history_statistics.dart';

class HistoryViewModel extends ChangeNotifier {
  final Training training;
  final HistoryRepository _historyRepository;
  final TrainingEventGenerator _eventGenerator;
  final Map<Command<Object>, VoidCallback> _commandListeners = {};

  late final Command0<List<HistoryEntry>> loadCommand;
  late final Command1<Unit, HistoryCommentUpdate> updateCommentsCommand;
  late final Command1<Unit, int> deleteCommand;

  List<TrainingEvent> _events = const [];
  HistoryStatistics _statistics = HistoryStatistics.empty;
  AppError? _lastError;

  HistoryViewModel({
    required this.training,
    required HistoryRepository historyRepository,
    TrainingEventGenerator eventGenerator = const TrainingEventGenerator(),
  })  : _historyRepository = historyRepository,
        _eventGenerator = eventGenerator {
    loadCommand = Command0<List<HistoryEntry>>(_load);
    updateCommentsCommand = Command1<Unit, HistoryCommentUpdate>(
      _updateComments,
    );
    deleteCommand = Command1<Unit, int>(_delete);

    for (final command in _commands) {
      void listener() => _onCommandChanged(command);
      _commandListeners[command] = listener;
      command.addListener(listener);
    }
  }

  int? get trainingId => training.id;

  List<HistoryEntry> get histories {
    final id = trainingId;
    return id == null ? const [] : _historyRepository.historiesForTraining(id);
  }

  List<TrainingEvent> get events => _events;

  List<SplitRecorded> get splits =>
      List.unmodifiable(_events.whereType<SplitRecorded>());

  List<LapRecorded> get laps =>
      List.unmodifiable(_events.whereType<LapRecorded>());

  HistoryStatistics get statistics => _statistics;

  AppError? get lastError => _lastError;

  bool get isLoading => _commands.any((command) => command.isRunning);

  Iterable<Command<Object>> get _commands => [
        loadCommand,
        updateCommentsCommand,
        deleteCommand,
      ];

  Future<void> load() => loadCommand.execute();

  Future<void> updateComments({
    required int historyEntryId,
    String? comments,
  }) =>
      updateCommentsCommand.execute(
        HistoryCommentUpdate(
          historyEntryId: historyEntryId,
          comments: comments,
        ),
      );

  Future<void> delete(int historyEntryId) =>
      deleteCommand.execute(historyEntryId);

  void clearLastError() {
    if (_lastError == null) return;
    _lastError = null;
    notifyListeners();
  }

  AsyncResult<List<HistoryEntry>> _load() async {
    final idResult = _requireTrainingId();
    if (idResult.isFailure) return Failure(idResult.error!);

    final result = await _historyRepository.loadForTraining(idResult.value!);
    if (result.isFailure) return Failure(result.error!);

    final presentation = _refreshPresentation();
    if (presentation.isFailure) return Failure(presentation.error!);
    return Success(result.value!);
  }

  AsyncResult<Unit> _updateComments(HistoryCommentUpdate update) async {
    final current = _findHistory(update.historyEntryId);
    if (current.isFailure) return Failure(current.error!);
    final entry = current.value!;
    final updated = HistoryEntry.create(
      id: entry.id,
      trainingId: entry.trainingId,
      duration: entry.duration,
      comments: update.comments,
    );
    if (updated.isFailure) return Failure(updated.error!);

    final result = await _historyRepository.update(updated.value!);
    if (result.isFailure) return Failure(result.error!);
    return _refreshPresentation();
  }

  AsyncResult<Unit> _delete(int historyEntryId) async {
    final idResult = _requireTrainingId();
    if (idResult.isFailure) return Failure(idResult.error!);

    final index = histories.indexWhere((entry) => entry.id == historyEntryId);
    if (index < 0) return Failure(_missingHistory(historyEntryId));
    if (index == 0 || index == histories.length - 1) {
      return Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message:
              'Only a history entry with adjacent measurements can be deleted.',
          details: historyEntryId,
        ),
      );
    }

    final result = await _historyRepository.deleteAndMergeNext(
      trainingId: idResult.value!,
      historyEntryId: historyEntryId,
    );
    if (result.isFailure) return Failure(result.error!);
    return _refreshPresentation();
  }

  Result<int> _requireTrainingId() {
    final id = trainingId;
    if (id != null) return Success(id);
    return const Failure(
      AppError(
        code: AppErrorCode.invalidData,
        message: 'A persisted training is required to manage histories.',
      ),
    );
  }

  Result<HistoryEntry> _findHistory(int historyEntryId) {
    final entry = histories
        .where((candidate) => candidate.id == historyEntryId)
        .firstOrNull;
    return entry == null
        ? Failure(_missingHistory(historyEntryId))
        : Success(entry);
  }

  AppError _missingHistory(int historyEntryId) => AppError(
        code: AppErrorCode.invalidData,
        message: 'The history entry is not available for this training.',
        details: historyEntryId,
      );

  Result<Unit> _refreshPresentation() {
    final generated = _eventGenerator.generate(
      training: training,
      histories: histories,
    );
    if (generated.isFailure) return Failure(generated.error!);

    final nextEvents = generated.value!;
    final nextSplits = nextEvents.whereType<SplitRecorded>().toList();
    final nextLaps = nextEvents.whereType<LapRecorded>().toList();
    _events = List.unmodifiable(nextEvents);
    _statistics = HistoryStatistics(
      persistedEntryCount: histories.length,
      splitCount: nextSplits.length,
      lapCount: nextLaps.length,
      measuredDuration: nextSplits.fold(
        Duration.zero,
        (total, split) => total + split.duration,
      ),
      measuredDistance: training.splitDistance.value * nextSplits.length,
    );
    return const Success(unit);
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
