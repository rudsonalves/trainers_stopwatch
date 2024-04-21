import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../common/constants.dart';
import '../../common/singletons/app_settings.dart';
import '../../common/theme/app_font_style.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const routeName = '/settings';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final appSettings = AppSettings.instance;
  bool _edited = false;

  IconData _themeModeIcon(ThemeMode theme) {
    switch (theme) {
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.light:
        return Icons.light_mode;
      default:
        return Icons.brightness_auto;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (_edited) appSettings.update();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('SetPAppBarTitle'.tr()),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'SetPDefault'.tr(),
                  style: AppFontStyle.roboto16SemiBold,
                ),
              ),
              Row(
                children: [
                  Text(
                    'SetPSplit'.tr(),
                    style: AppFontStyle.roboto16,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${appSettings.splitLength} m',
                    style: AppFontStyle.roboto16SemiBold,
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'SetPLap'.tr(),
                    style: AppFontStyle.roboto16,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${appSettings.lapLength} m',
                    style: AppFontStyle.roboto16SemiBold,
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  Text(
                    'SetPTheme'.tr(),
                    style: AppFontStyle.roboto16,
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<ThemeMode>(
                    value: appSettings.themeMode.watch(context),
                    items: ThemeMode.values
                        .map(
                          (theme) => DropdownMenuItem<ThemeMode>(
                            value: theme,
                            child: Row(
                              children: [
                                Icon(_themeModeIcon(theme)),
                                const SizedBox(width: 8),
                                Text(theme.name),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      appSettings.setThemeMode(value);
                      _edited;
                    },
                  )
                ],
              ),
              Row(
                children: [
                  Text('SetPLang'.tr(), style: AppFontStyle.roboto16),
                  const SizedBox(width: 12),
                  DropdownButton<Locale>(
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
                                '${entry.value.flag} - ${entry.value.localeCode}'),
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
                        appSettings.mSecondRefresh = value;
                        _edited = true;
                        setState(() {});
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
