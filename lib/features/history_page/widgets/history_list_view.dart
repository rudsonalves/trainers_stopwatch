import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../common/abstract_classes/history_controller.dart';
import '../../../models/history_model.dart';
import '../../widgets/common/dismissible_history.dart';

class HistoryListView extends StatelessWidget {
  final HistoryController controller;
  final List<HistoryModel> histories;
  final Future<void> Function(HistoryModel history) updateHistory;
  final Future<void> Function(HistoryModel history) deleteHistory;
  final bool reversed;

  const HistoryListView({
    super.key,
    required this.controller,
    required this.histories,
    required this.updateHistory,
    required this.deleteHistory,
    this.reversed = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.secondaryContainer,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          switch (controller.state) {
            case StateLoading():
              return const Center(
                child: CircularProgressIndicator(),
              );
            case StateSuccess():
              final sortHist =
                  reversed ? histories.reversed.toList() : histories;

              return ListView.builder(
                itemCount: sortHist.length,
                itemBuilder: (context, index) => DismissibleHistory(
                  history: sortHist[index],
                  managerUpdade: updateHistory,
                  managerDelete: deleteHistory,
                ),
              );
            default:
              return Center(
                child: Text('TPError'.tr()),
              );
          }
        },
      ),
    );
  }
}
