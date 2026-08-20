import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '/common/theme/app_font_style.dart';
import '/features/widgets/precise_stopwatch/precise_stopwatch.dart';
import '/ui/pages/history/viewmodel/history_view_model.dart';
import '/ui/pages/history/widgets/history_list_view.dart';

class PersonalTrainingPage extends StatefulWidget {
  final PreciseStopwatch stopwatch;
  final HistoryViewModel viewModel;

  const PersonalTrainingPage({
    super.key,
    required this.stopwatch,
    required this.viewModel,
  });

  @override
  State<PersonalTrainingPage> createState() => _PersonalTrainingPageState();
}

class _PersonalTrainingPageState extends State<PersonalTrainingPage> {
  HistoryViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    widget.stopwatch.controller.actionOnPress.addListener(_reloadHistory);
    viewModel.load();
  }

  void _reloadHistory() => viewModel.load();

  Future<bool> _deleteHistory(int historyEntryId) async {
    await viewModel.delete(historyEntryId);
    return viewModel.deleteCommand.isSuccess;
  }

  @override
  void dispose() {
    widget.stopwatch.controller.actionOnPress.removeListener(_reloadHistory);
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
        Expanded(
          child: HistoryListView(
            events: viewModel.events,
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
      appBar: AppBar(title: Text(widget.stopwatch.user.name)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PreciseStopwatch(
              user: widget.stopwatch.user,
              controller: widget.stopwatch.controller,
              isNotClone: false,
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
