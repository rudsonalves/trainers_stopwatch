// Copyright (C) 2024 Rudson Alves
//
// This file is part of trainers_stopwatch.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'viewmodel/settings_view_model.dart';
import 'widgets/error_message.dart';
import 'widgets/settings_form.dart';

class SettingsPage extends StatefulWidget {
  final SettingsViewModel viewModel;

  const SettingsPage({super.key, required this.viewModel});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SettingsViewModel get viewModel => widget.viewModel;

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

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: Listenable.merge([
          viewModel,
          viewModel.loadCommand,
          viewModel.saveCommand,
        ]),
        builder: (context, _) => Scaffold(
          appBar: AppBar(
            title: Text('SetPAppBarTitle'.tr()),
            elevation: 5,
          ),
          body: _buildBody(context),
        ),
      );

  Widget _buildBody(BuildContext context) {
    final data = viewModel.state;
    if (data == null) {
      if (viewModel.loadCommand.isFailure) {
        return ErrorMessage(message: 'TPError'.tr());
      }
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        if (viewModel.loadCommand.isRunning || viewModel.saveCommand.isRunning)
          const LinearProgressIndicator(),
        if (viewModel.loadCommand.isFailure)
          ErrorMessage(message: 'TPError'.tr()),
        if (viewModel.saveCommand.isFailure)
          ErrorMessage(message: 'TPError'.tr()),
        Expanded(
          child: AbsorbPointer(
            absorbing: viewModel.loadCommand.isRunning,
            child: SettingsForm(data: data, viewModel: viewModel),
          ),
        ),
      ],
    );
  }
}
