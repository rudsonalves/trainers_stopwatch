// Copyright (C) 2024 Rudson Alves
//
// This file is part of trainers_stopwatch.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/application/stopwatch/session/stopwatch_session_id.dart';
import '/application/stopwatch/session/stopwatch_session_view_model.dart';
import '/core/routing/route_arguments.dart';
import '/core/routing/routes.dart';
import '/ui/pages/settings/viewmodel/settings_view_model.dart';
import '/ui/pages/stopwatch/stopwatch_page_view_model.dart';
import '../../components/generic_dialog.dart';
import 'widgets/message_row.dart';
import 'widgets/stopwatch_dismissible.dart';
import 'widgets/stopwatch_drawer.dart';

const double stopWatchHeight = 134;

class StopWatchPage extends StatefulWidget {
  final StopwatchPageViewModel viewModel;
  final SettingsViewModel settingsViewModel;

  const StopWatchPage({
    super.key,
    required this.viewModel,
    required this.settingsViewModel,
  });

  @override
  State<StopWatchPage> createState() => _StopWatchPageState();
}

class _StopWatchPageState extends State<StopWatchPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  StopwatchPageViewModel get viewModel => widget.viewModel;

  Future<void> _addStopwatches() =>
      context.pushNamed(MainRoutes.users.routeName);

  Future<bool> _removeStopwatch(StopwatchSessionId id) async {
    var confirmed = true;
    if (viewModel.requiresRemovalConfirmation(id)) {
      confirmed = await GenericDialog.open(
        context,
        title: 'SPRemoveTraining'.tr(),
        message: 'SPLongMsg'.tr(),
        actions: DialogActions.yesNo,
      );
    }
    if (!confirmed) return false;

    final result = await viewModel.removeSession(id, confirmed: confirmed);
    if (result.isFailure && mounted) {
      await GenericDialog.open(
        context,
        title: 'SPRemoveTraining'.tr(),
        message: 'TPError'.tr(),
        actions: DialogActions.close,
      );
    }
    return result.isSuccess;
  }

  Future<void> _manageStopwatch(StopwatchSessionViewModel session) async {
    await context.pushNamed(
      MainRoutes.personalTraining.routeName,
      extra: PersonalTrainingRouteArguments(sessionId: session.id),
    );
  }

  Widget _stopwatchListView() {
    return SizedBox(
      height: _sizedBoxHeight(),
      child: viewModel.sessions.isEmpty
          ? Center(child: Text('SPNoSessions'.tr()))
          : ListView.builder(
              itemCount: viewModel.sessions.length,
              itemBuilder: (context, index) {
                final session = viewModel.sessions[index];
                return StopwatDismissible(
                  key: ValueKey(session.id.userId),
                  enabled: !viewModel.isRemoving(session.id),
                  session: session,
                  removeStopwatch: _removeStopwatch,
                  managerStopwatch: _manageStopwatch,
                );
              },
            ),
    );
  }

  Widget _logTimes() {
    final colorScheme = Theme.of(context).colorScheme;
    final messages = viewModel.messages.reversed.toList(growable: false);
    return Expanded(
      child: Focus(
        child: Container(
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.secondaryContainer),
          ),
          padding: const EdgeInsets.all(6),
          child: messages.isEmpty
              ? Center(child: Text('SPNoRecords'.tr()))
              : ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) => MessageRow(
                    message: messages[index],
                  ),
                ),
        ),
      ),
    );
  }

  double _sizedBoxHeight() {
    var length = viewModel.sessions.length.clamp(1, 4);
    return length * stopWatchHeight;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 4,
        title: Text('SPAppBarTitle'.tr()),
        actions: [
          ListenableBuilder(
            listenable: widget.settingsViewModel,
            builder: (context, _) {
              final brightness = widget.settingsViewModel.state?.brightness;

              return IconButton(
                icon: Icon(
                  brightness == Brightness.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                onPressed: brightness == null
                    ? null
                    : widget.settingsViewModel.toggleBrightness,
              );
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: StopwatchDrawer(addStopwatchs: _addStopwatches),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) => Column(
            children: [_stopwatchListView(), _logTimes()],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStopwatches,
        child: Icon(
          Icons.group_add,
          color: colorScheme.primary.withValues(alpha: .5),
        ),
      ),
    );
  }
}
