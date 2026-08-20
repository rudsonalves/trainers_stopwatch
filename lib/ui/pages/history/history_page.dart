import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '/domain/common/user/models/user.dart';
import 'viewmodel/history_view_model.dart';
import 'widgets/history_list_view.dart';
import 'widgets/training_informations.dart';

class HistoryPage extends StatefulWidget {
  final User user;
  final HistoryViewModel viewModel;

  const HistoryPage({
    super.key,
    required this.user,
    required this.viewModel,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  HistoryViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    viewModel.load();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Future<bool> _deleteHistory(int historyEntryId) async {
    await viewModel.delete(historyEntryId);
    return viewModel.deleteCommand.isSuccess;
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
            histories: viewModel.histories,
            updateComments: viewModel.updateComments,
            deleteHistory: _deleteHistory,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('HPTile'.tr())),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            children: [
              TrainingInformations(
                user: widget.user,
                training: viewModel.training,
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
