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
import 'package:onboarding_overlay/onboarding_overlay.dart';

import '../../common/constants.dart';
import '../../common/singletons/app_settings.dart';
import '../../common/theme/app_font_style.dart';
import '../../common/models/settings_model.dart';
import 'widgets/length_line_edit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final app = AppSettings.instance;
  late final OnboardingState? overlay;

  bool _edited = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        overlay = Onboarding.of(context);
      },
    );
  }

  Widget _brightnessIcon(Brightness brightness) {
    return Icon(
      brightness == Brightness.light ? Icons.light_mode : Icons.dark_mode,
    );
  }

  void _startTutorial() {
    if (app.tutorialOn) {
      if (overlay != null) {
        overlay!.show();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: true,
      // onPopInvoked: (didPop) {
      //   if (_edited) app.update();
      // },
      onPopInvokedWithResult: (didPop, _) {
        if (_edited) app.update();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('SetPAppBarTitle'.tr()),
          elevation: 5,
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.menu),
              itemBuilder: (context) => <PopupMenuEntry>[
                PopupMenuItem(
                  onTap: () {
                    app.tutorialOn = true;
                    _startTutorial();
                  },
                  child: const ListTile(
                    leading: Icon(Icons.question_mark),
                    title: Text('Tutorial'),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Focus(
                focusNode: app.focusNodes[19],
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        'SetPDefault'.tr(),
                        style: AppFontStyle.roboto16SemiBold
                            .copyWith(color: colorScheme.primary),
                      ),
                    ),
                    LengthLineEdit(
                      lengthLabel: 'SetPSplit'.tr(),
                      length: app.splitLength,
                      lengthUnit: app.lengthUnit,
                    ),
                    LengthLineEdit(
                      lengthLabel: 'SetPLap'.tr(),
                      length: app.lapLength,
                      lengthUnit: app.lengthUnit,
                    ),
                  ],
                ),
              ),
              const Divider(),
              Focus(
                focusNode: app.focusNodes[20],
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'SetPTheme'.tr(),
                          style: AppFontStyle.roboto16,
                        ),
                        const SizedBox(width: 12),
                        ValueListenableBuilder(
                          valueListenable: app.brightnessMode,
                          builder: (context, value, _) =>
                              IconButton.filledTonal(
                            onPressed: app.toggleBrightnessMode,
                            icon: _brightnessIcon(value),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Contrast:',
                          style: AppFontStyle.roboto16,
                        ),
                        const SizedBox(width: 12),
                        ValueListenableBuilder(
                          valueListenable: app.contrastMode,
                          builder: (context, value, _) =>
                              SegmentedButton<Contrast>(
                            showSelectedIcon: false,
                            segments: const [
                              ButtonSegment(
                                value: Contrast.standard,
                                icon: Icon(Icons.brightness_5),
                              ),
                              ButtonSegment(
                                value: Contrast.medium,
                                icon: Icon(Icons.brightness_6),
                              ),
                              ButtonSegment(
                                value: Contrast.high,
                                icon: Icon(Icons.brightness_7),
                              ),
                            ],
                            selected: {value},
                            onSelectionChanged: (value) {
                              setState(() {
                                app.setContrast(value.first);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Focus(
                focusNode: app.focusNodes[21],
                child: Row(
                  children: [
                    Text('SetPLang'.tr(), style: AppFontStyle.roboto16),
                    const SizedBox(width: 12),
                    DropdownButton<Locale>(
                      borderRadius: BorderRadius.circular(12),
                      dropdownColor: colorScheme.primaryContainer,
                      value: app.language,
                      onChanged: (value) {
                        if (value == null) return;
                        app.language = value;
                        _edited = true;
                        context.setLocale(app.language);
                        setState(() {});
                      },
                      items: appLanguages.entries
                          .map(
                            (entry) => DropdownMenuItem<Locale>(
                              value: entry.value.locale,
                              child: Text(
                                '${entry.value.flag} - ${entry.value.localeCode}',
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              Focus(
                focusNode: app.focusNodes[22],
                child: Row(
                  children: [
                    Text(
                      'SetPRefresh'.tr(),
                      style: AppFontStyle.roboto16,
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      borderRadius: BorderRadius.circular(12),
                      dropdownColor: colorScheme.primaryContainer,
                      value: app.mSecondRefresh,
                      items: millisecondRefreshValues
                          .map(
                            (value) => DropdownMenuItem<int>(
                              value: value,
                              child: Text(
                                '$value ms',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            app.mSecondRefresh = value;
                            _edited = true;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
