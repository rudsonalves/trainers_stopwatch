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
import 'package:go_router/go_router.dart';

import '/common/theme/theme.dart';
import '/common/theme/util.dart';
import '/core/routing/router.dart';
import '/core/routing/routes/main_routes.dart';
import '/domain/common/training/models/training.dart';
import '/ui/pages/history/viewmodel/history_view_model.dart';
import '/ui/pages/settings/viewmodel/settings_view_model.dart';
import '/ui/pages/stopwatch/stopwatch_page_view_model.dart';
import '/ui/pages/trainings/viewmodel/trainings_view_model.dart';
import '/ui/pages/users/viewmodel/users_view_model.dart';
import 'app_appearance_state.dart';

class MyMaterialApp extends StatefulWidget {
  final StopwatchPageViewModel stopwatchViewModel;
  final SettingsViewModel stopwatchSettingsViewModel;
  final UsersViewModel Function(Iterable<int> activeUserIds)
      usersViewModelFactory;
  final TrainingsViewModel Function() trainingsViewModelFactory;
  final HistoryViewModel Function(Training training) historyViewModelFactory;
  final AppAppearanceState appearanceState;
  final SettingsViewModel Function() settingsViewModelFactory;

  const MyMaterialApp({
    super.key,
    required this.stopwatchViewModel,
    required this.stopwatchSettingsViewModel,
    required this.usersViewModelFactory,
    required this.trainingsViewModelFactory,
    required this.historyViewModelFactory,
    required this.appearanceState,
    required this.settingsViewModelFactory,
  });

  @override
  State<MyMaterialApp> createState() => _MyMaterialAppState();
}

class _MyMaterialAppState extends State<MyMaterialApp> {
  bool _localeSyncScheduled = false;
  late final GoRouter _router;

  AppAppearanceState get appearanceState => widget.appearanceState;

  @override
  void initState() {
    super.initState();
    _router = createRouter(
      MainRouteDependencies(
        stopwatchViewModel: widget.stopwatchViewModel,
        stopwatchSettingsViewModel: widget.stopwatchSettingsViewModel,
        usersViewModelFactory: widget.usersViewModelFactory,
        trainingsViewModelFactory: widget.trainingsViewModelFactory,
        historyViewModelFactory: widget.historyViewModelFactory,
        settingsViewModelFactory: widget.settingsViewModelFactory,
      ),
    );
    appearanceState.addListener(_onAppearanceChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleLocaleSync();
  }

  @override
  void didUpdateWidget(covariant MyMaterialApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appearanceState == appearanceState) return;
    oldWidget.appearanceState.removeListener(_onAppearanceChanged);
    appearanceState.addListener(_onAppearanceChanged);
    _scheduleLocaleSync();
  }

  @override
  void dispose() {
    appearanceState.removeListener(_onAppearanceChanged);
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Roboto", "Actor");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp.router(
      routerConfig: _router,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: appearanceState.locale,
      theme: appearanceState.brightness == Brightness.light
          ? _lightContrast(theme, appearanceState.contrast)
          : _darkContrast(theme, appearanceState.contrast),
      debugShowCheckedModeBanner: false,
    );
  }

  void _onAppearanceChanged() {
    if (!mounted) return;
    setState(() {});
    _scheduleLocaleSync();
  }

  void _scheduleLocaleSync() {
    if (_localeSyncScheduled) return;
    _localeSyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _localeSyncScheduled = false;
      if (!mounted || context.locale == appearanceState.locale) return;
      await context.setLocale(appearanceState.locale);
    });
  }

  ThemeData _lightContrast(MaterialTheme theme, AppContrast contrast) {
    switch (contrast) {
      case AppContrast.standard:
        return theme.light();
      case AppContrast.medium:
        return theme.lightMediumContrast();
      case AppContrast.high:
        return theme.lightHighContrast();
    }
  }

  ThemeData _darkContrast(MaterialTheme theme, AppContrast contrast) {
    switch (contrast) {
      case AppContrast.standard:
        return theme.dark();
      case AppContrast.medium:
        return theme.darkMediumContrast();
      case AppContrast.high:
        return theme.darkHighContrast();
    }
  }
}
