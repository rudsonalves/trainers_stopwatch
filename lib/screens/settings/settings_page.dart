import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../common/constants.dart';
import '../../common/singletons/app_settings.dart';
import '../../common/theme/app_font_style.dart';
import '../../models/settings_model.dart';
import 'widgets/length_line_edit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const routeName = '/settings';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final appSettings = AppSettings.instance;

  bool _edited = false;

  Widget _brightnessIcon(Brightness brightness) {
    return Icon(
      brightness == Brightness.light ? Icons.light_mode : Icons.dark_mode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (_edited) appSettings.update();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('SetPAppBarTitle'.tr()),
          elevation: 5,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                length: appSettings.splitLength,
                lengthUnit: appSettings.lengthUnit,
              ),
              LengthLineEdit(
                lengthLabel: 'SetPLap'.tr(),
                length: appSettings.lapLength,
                lengthUnit: appSettings.lengthUnit,
              ),
              const Divider(),
              Row(
                children: [
                  Text(
                    'SetPTheme'.tr(),
                    style: AppFontStyle.roboto16,
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    onPressed: appSettings.toggleBrightnessMode,
                    icon: _brightnessIcon(appSettings.brightnessMode.watch(
                      context,
                    )),
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
                    selected: {appSettings.contrastMode.watch(context)},
                    onSelectionChanged: (value) {
                      setState(() {
                        appSettings.setContrast(value.first);
                      });
                    },
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
                    value: appSettings.language,
                    onChanged: (value) {
                      if (value == null) return;
                      appSettings.language = value;
                      _edited = true;
                      context.setLocale(appSettings.language);
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
              Row(
                children: [
                  Text(
                    'SetPRefresh'.tr(),
                    style: AppFontStyle.roboto16,
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    borderRadius: BorderRadius.circular(12),
                    dropdownColor: colorScheme.primaryContainer,
                    value: appSettings.mSecondRefresh,
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
                          appSettings.mSecondRefresh = value;
                          _edited = true;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
