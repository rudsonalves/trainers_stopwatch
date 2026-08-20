// Copyright (C) 2024 Rudson Alves
//
// This file is part of trainers_stopwatch.

import 'package:flutter/material.dart';

import 'viewmodel/settings_view_model.dart';
import 'settings_page.dart';

class SettingsOverlay extends StatefulWidget {
  final SettingsViewModel viewModel;

  const SettingsOverlay({super.key, required this.viewModel});

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay> {
  @override
  Widget build(BuildContext context) => SettingsPage(
        viewModel: widget.viewModel,
      );

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }
}
