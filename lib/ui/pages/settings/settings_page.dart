// Copyright (C) 2024 Rudson Alves
//
// This file is part of trainers_stopwatch.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '/common/constants.dart';
import '/common/theme/app_font_style.dart';
import '/domain/common/training/units/distance_unit.dart';
import '/ui/app/app_appearance_state.dart';
import 'viewmodel/models/settings_form_data.dart';
import 'viewmodel/settings_view_model.dart';
import 'widgets/length_line_edit.dart';

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
        return _ErrorMessage(message: viewModel.loadCommand.error!.message);
      }
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        if (viewModel.loadCommand.isRunning || viewModel.saveCommand.isRunning)
          const LinearProgressIndicator(),
        if (viewModel.loadCommand.isFailure)
          _ErrorMessage(message: viewModel.loadCommand.error!.message),
        if (viewModel.saveCommand.isFailure)
          _ErrorMessage(message: viewModel.saveCommand.error!.message),
        Expanded(child: _SettingsForm(data: data, viewModel: viewModel)),
      ],
    );
  }
}

class _SettingsForm extends StatelessWidget {
  final SettingsFormData data;
  final SettingsViewModel viewModel;

  const _SettingsForm({required this.data, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Center(
                child: Text(
                  'SetPDefault'.tr(),
                  style: AppFontStyle.roboto16SemiBold.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
              LengthLineEdit(
                lengthLabel: 'SetPSplit'.tr(),
                length: data.splitDistance,
                lengthUnit: data.distanceUnit.symbol,
                onLengthChanged: viewModel.setSplitDistance,
                onUnitChanged: (symbol) {
                  final unit = DistanceUnit.fromSymbol(symbol);
                  if (unit.isSuccess) viewModel.setDistanceUnit(unit.value!);
                },
              ),
              LengthLineEdit(
                lengthLabel: 'SetPLap'.tr(),
                length: data.lapDistance,
                lengthUnit: data.distanceUnit.symbol,
                onLengthChanged: viewModel.setLapDistance,
                onUnitChanged: (symbol) {
                  final unit = DistanceUnit.fromSymbol(symbol);
                  if (unit.isSuccess) viewModel.setDistanceUnit(unit.value!);
                },
              ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              Text('SetPTheme'.tr(), style: AppFontStyle.roboto16),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                onPressed: () => viewModel.setBrightness(
                  data.brightness == Brightness.light
                      ? Brightness.dark
                      : Brightness.light,
                ),
                icon: Icon(
                  data.brightness == Brightness.light
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Contrast:', style: AppFontStyle.roboto16),
              const SizedBox(width: 12),
              SegmentedButton<AppContrast>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: AppContrast.standard,
                    icon: Icon(Icons.brightness_5),
                  ),
                  ButtonSegment(
                    value: AppContrast.medium,
                    icon: Icon(Icons.brightness_6),
                  ),
                  ButtonSegment(
                    value: AppContrast.high,
                    icon: Icon(Icons.brightness_7),
                  ),
                ],
                selected: {data.contrast},
                onSelectionChanged: (value) =>
                    viewModel.setContrast(value.first),
              ),
            ],
          ),
          Row(
            children: [
              Text('SetPLang'.tr(), style: AppFontStyle.roboto16),
              const SizedBox(width: 12),
              DropdownButton<Locale>(
                borderRadius: BorderRadius.circular(12),
                dropdownColor: colorScheme.primaryContainer,
                value: data.locale,
                onChanged: (value) {
                  if (value != null) viewModel.setLocale(value);
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
          Row(
            children: [
              Text('SetPRefresh'.tr(), style: AppFontStyle.roboto16),
              const SizedBox(width: 12),
              DropdownButton<int>(
                borderRadius: BorderRadius.circular(12),
                dropdownColor: colorScheme.primaryContainer,
                value: data.refreshInterval.inMilliseconds,
                items: millisecondRefreshValues
                    .map(
                      (value) => DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value ms'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    viewModel.setRefreshInterval(
                      Duration(milliseconds: value),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String message;

  const _ErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
}
