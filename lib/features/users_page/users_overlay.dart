// Copyright (C) 2024 Rudson Alves
//
// This file is part of trainers_stopwatch.

import 'package:flutter/material.dart';

import '../stopwatch_page/stopwatch_page_controller.dart';
import 'users_page.dart';
import 'users_page_controller.dart';

class UsersOverlay extends StatelessWidget {
  final UsersPageController controller;
  final StopwatchPageController stopwatchController;

  const UsersOverlay({
    super.key,
    required this.controller,
    required this.stopwatchController,
  });

  static const routeName = '/users';

  @override
  Widget build(BuildContext context) => UsersPage(
        controller: controller,
        stopwatchController: stopwatchController,
      );
}
