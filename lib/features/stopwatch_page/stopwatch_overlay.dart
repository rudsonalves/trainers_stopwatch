// Copyright (C) 2024 Rudson Alves
//
// This file is part of trainers_stopwatch.

import 'package:flutter/material.dart';

import 'stopwatch_page.dart';
import 'stopwatch_page_controller.dart';

class StopwatchOverlay extends StatelessWidget {
  final StopwatchPageController controller;

  const StopwatchOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => StopWatchPage(controller: controller);
}
