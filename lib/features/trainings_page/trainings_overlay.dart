// Copyright (C) 2024 Rudson Alves
//
// This file is part of trainers_stopwatch.

import 'package:flutter/material.dart';

import '../../common/functions/share_functions.dart';
import 'trainings_page.dart';
import 'trainings_page_controller.dart';

class TrainingsOverlay extends StatelessWidget {
  final TrainingsPageController controller;
  final AppShare appShare;

  const TrainingsOverlay({
    super.key,
    required this.controller,
    required this.appShare,
  });

  @override
  Widget build(BuildContext context) => TrainingsPage(
        controller: controller,
        appShare: appShare,
      );
}
