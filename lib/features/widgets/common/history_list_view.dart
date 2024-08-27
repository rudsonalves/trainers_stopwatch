// Copyright (C) 2024 Rudson Alves
// 
// This file is part of trainers_stopwatch.
// 
// trainers_stopwatch is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// trainers_stopwatch is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with trainers_stopwatch.  If not, see <https://www.gnu.org/licenses/>.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../common/abstract_classes/history_controller.dart';
import '../../../common/models/history_model.dart';
import '../../../common/models/messages_model.dart';
import '../../../common/models/training_model.dart';
import '../../../common/models/user_model.dart';
import 'dismissible_history.dart';
import 'edit_history_dialog.dart';

class HistoryListView extends StatefulWidget {
  final HistoryController controller;
  final UserModel user;
  final TrainingModel training;
  final List<HistoryModel> histories;
  final Future<bool> Function(HistoryModel history) updateHistory;
  final Future<bool> Function(int historyId) deleteHistory;
  final bool reversed;

  const HistoryListView({
    super.key,
    required this.controller,
    required this.user,
    required this.training,
    required this.histories,
    required this.updateHistory,
    required this.deleteHistory,
    this.reversed = false,
  });

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  @override
  void initState() {
    super.initState();
  }

  Future<bool> editHistory(int historyId) async {
    final history = widget.histories.firstWhere((h) => h.id == historyId);
    final title = widget.controller.messages
        .firstWhere((m) => m.historyId == historyId)
        .title;
    if (mounted) {
      await EditHistoryDialog.open(
        context,
        title: title,
        history: history,
      );
    }

    await widget.updateHistory(history);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final messages = widget.controller.messages;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.secondaryContainer,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          switch (widget.controller.state) {
            case StateLoading():
              return const Center(
                child: CircularProgressIndicator(),
              );
            case StateSuccess():
              final showMsgs =
                  widget.reversed ? messages.reversed.toList() : messages;

              return ListView.builder(
                itemCount: showMsgs.length,
                itemBuilder: (context, index) => DismissibleHistory(
                  message: showMsgs[index],
                  enableDelete: index == 0 || index == showMsgs.length - 1
                      ? false
                      : showMsgs[index].msgType == MessageType.isSplit
                          ? true
                          : false,
                  editHistory: editHistory,
                  managerDelete: widget.deleteHistory,
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
