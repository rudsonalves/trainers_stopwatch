import 'package:easy_localization/easy_localization.dart';

import '../../domain/common/training/services/training_event_generator.dart';
import '../adapters/history_domain_adapter.dart';
import '../adapters/training_domain_adapter.dart';
import '../models/history_model.dart';
import '../models/messages_model.dart';
import '../models/training_model.dart';
import '../models/user_model.dart';
import '../presentation/training_event_message_mapper.dart';

class HistoryIndex {
  final bool isLap;
  final int lapIndex;
  final int splitIndex;

  HistoryIndex({
    required this.isLap,
    required this.lapIndex,
    required this.splitIndex,
  });
}

class TrainingReport {
  final UserModel user;
  final TrainingModel training;
  final List<HistoryModel> histories;
  final List<MessagesModel> _messages = [];

  List<MessagesModel> get messages => _messages;

  TrainingReport({
    required this.user,
    required this.training,
    required this.histories,
  });

  void createMessages() {
    final domainTraining = training.toDomain();
    if (domainTraining.isFailure) throw domainTraining.error!;

    final domainHistories = histories.map((history) {
      final result = history.toDomain();
      if (result.isFailure) throw result.error!;
      return result.value!;
    }).toList(growable: false);

    final events = const TrainingEventGenerator().generate(
      training: domainTraining.value!,
      histories: domainHistories,
    );
    if (events.isFailure) throw events.error!;

    const mapper = TrainingEventMessageMapper();
    final startedLabel = 'HPCTrainingStarting'.tr();
    final mappedMessages = events.value!
        .map(
          (event) => mapper.map(
            event: event,
            userName: user.name,
            color: training.color,
            startedLabel: startedLabel,
          ),
        )
        .toList(growable: false);

    _messages
      ..clear()
      ..addAll(mappedMessages);
  }

  static HistoryIndex getIndex(int index, int splitsPerLap) {
    if (index < 0 || splitsPerLap <= 0) {
      return HistoryIndex(isLap: false, lapIndex: 0, splitIndex: 0);
    }

    final lapIndex = index ~/ splitsPerLap;
    var splitIndex = index % splitsPerLap;
    splitIndex = splitIndex == 0 ? splitsPerLap : splitIndex;

    return HistoryIndex(
      isLap: splitIndex == splitsPerLap && lapIndex != 0,
      lapIndex: lapIndex,
      splitIndex: splitIndex,
    );
  }
}
