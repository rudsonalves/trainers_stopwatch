// Copyright (C) 2024 Rudson Alves
//
// This file is part of trainers_stopwatch.

import 'package:flutter/material.dart';

import '/features/stopwatch_page/stopwatch_page_controller.dart';
import 'viewmodel/users_view_model.dart';
import 'users_page.dart';

class UsersOverlay extends StatefulWidget {
  final UsersViewModel viewModel;
  final StopwatchPageController stopwatchController;

  const UsersOverlay({
    super.key,
    required this.viewModel,
    required this.stopwatchController,
  });

  @override
  State<UsersOverlay> createState() => _UsersOverlayState();
}

class _UsersOverlayState extends State<UsersOverlay> {
  @override
  Widget build(BuildContext context) => UsersPage(
        viewModel: widget.viewModel,
        stopwatchController: widget.stopwatchController,
      );

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }
}
