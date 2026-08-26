import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '/application/stopwatch/session/stopwatch_session_view_model.dart';
import '/common/theme/app_font_style.dart';
import '/ui/pages/history/viewmodel/history_view_model.dart';
import '/ui/pages/history/widgets/history_list_view.dart';
import '../../components/precise_stopwatch/precise_stopwatch.dart';

class PersonalTrainingPage extends StatefulWidget {
  final StopwatchSessionViewModel session;
  final HistoryViewModel viewModel;

  const PersonalTrainingPage({
    super.key,
    required this.session,
    required this.viewModel,
  });

  @override
  State<PersonalTrainingPage> createState() => _PersonalTrainingPageState();
}

class _PersonalTrainingPageState extends State<PersonalTrainingPage> {
  late int _messageCount;
  HistoryViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _messageCount = widget.session.state.messages.length;
    widget.session.addListener(_onSessionChanged);
    viewModel.load();
  }

  void _onSessionChanged() {
    final messageCount = widget.session.state.messages.length;
    if (messageCount == _messageCount) return;
    _messageCount = messageCount;
    viewModel.load();
  }

  Future<bool> _deleteHistory(int historyEntryId) async {
    await viewModel.delete(historyEntryId);
    return viewModel.deleteCommand.isSuccess;
  }

  @override
  void dispose() {
    widget.session.removeListener(_onSessionChanged);
    viewModel.dispose();
    super.dispose();
  }

  Widget _buildHistory() {
    if (viewModel.loadCommand.isRunning && viewModel.events.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.loadCommand.isFailure && viewModel.events.isEmpty) {
      return Center(child: Text('TPError'.tr()));
    }
    return Column(
      children: [
        if (viewModel.isLoading) const LinearProgressIndicator(),
        if (viewModel.lastError != null)
          Padding(
            padding: const EdgeInsets.all(4),
            child: Text('TPError'.tr()),
          ),
        Expanded(
          child: HistoryListView(
            events: viewModel.events,
            enabled: !viewModel.isLoading,
            histories: viewModel.histories,
            updateComments: viewModel.updateComments,
            deleteHistory: _deleteHistory,
            reversed: true,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final training = viewModel.training;
    final unit = training.splitDistance.unit.symbol;
    return Scaffold(
      appBar: AppBar(title: Text(widget.session.user.name)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PreciseStopwatch(
              session: widget.session,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Split: ${training.splitDistance.value} $unit',
                style: AppFontStyle.roboto16,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Lap: ${training.lapDistance.value} $unit',
                style: AppFontStyle.roboto16,
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: viewModel,
                builder: (context, _) => _buildHistory(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
