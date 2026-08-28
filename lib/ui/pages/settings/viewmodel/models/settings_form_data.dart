import 'dart:ui';

import '/core/result/result.dart';
import '/domain/common/settings/models/settings.dart';
import '/domain/common/training/units/distance_unit.dart';
import '/domain/common/training/values/distance.dart';
import '/ui/app/app_appearance_state.dart';

class SettingsFormData {
  final int? id;
  final double splitDistance;
  final double lapDistance;
  final DistanceUnit distanceUnit;
  final Brightness brightness;
  final AppContrast contrast;
  final Locale locale;
  final Duration refreshInterval;
  final bool protectedActionsHintSeen;

  const SettingsFormData({
    required this.id,
    required this.splitDistance,
    required this.lapDistance,
    required this.distanceUnit,
    required this.brightness,
    required this.contrast,
    required this.locale,
    required this.refreshInterval,
    required this.protectedActionsHintSeen,
  });

  factory SettingsFormData.fromDomain(Settings settings) => SettingsFormData(
        id: settings.id,
        splitDistance: settings.splitDistance.value,
        lapDistance: settings.lapDistance.value,
        distanceUnit: settings.splitDistance.unit,
        protectedActionsHintSeen: settings.protectedActionsHintSeen,
        brightness: switch (settings.brightness) {
          BrightnessPreference.light => Brightness.light,
          BrightnessPreference.dark => Brightness.dark,
        },
        contrast: switch (settings.contrast) {
          ContrastPreference.standard => AppContrast.standard,
          ContrastPreference.medium => AppContrast.medium,
          ContrastPreference.high => AppContrast.high,
        },
        locale: Locale(
          settings.language.languageCode,
          settings.language.countryCode,
        ),
        refreshInterval: settings.refreshInterval,
      );

  Result<Settings> toDomain() {
    final split = Distance.create(value: splitDistance, unit: distanceUnit);
    if (split.isFailure) return Failure(split.error!);

    final lap = Distance.create(value: lapDistance, unit: distanceUnit);
    if (lap.isFailure) return Failure(lap.error!);

    return Settings.create(
      id: id,
      splitDistance: split.value!,
      lapDistance: lap.value!,
      protectedActionsHintSeen: protectedActionsHintSeen,
      brightness: switch (brightness) {
        Brightness.light => BrightnessPreference.light,
        Brightness.dark => BrightnessPreference.dark,
      },
      contrast: switch (contrast) {
        AppContrast.standard => ContrastPreference.standard,
        AppContrast.medium => ContrastPreference.medium,
        AppContrast.high => ContrastPreference.high,
      },
      language: LanguagePreference(locale.languageCode, locale.countryCode),
      refreshInterval: refreshInterval,
    );
  }

  SettingsFormData copyWith({
    double? splitDistance,
    double? lapDistance,
    DistanceUnit? distanceUnit,
    bool? protectedActionsHintSeen,
    Brightness? brightness,
    AppContrast? contrast,
    Locale? locale,
    Duration? refreshInterval,
  }) =>
      SettingsFormData(
        id: id,
        splitDistance: splitDistance ?? this.splitDistance,
        lapDistance: lapDistance ?? this.lapDistance,
        distanceUnit: distanceUnit ?? this.distanceUnit,
        protectedActionsHintSeen:
            protectedActionsHintSeen ?? this.protectedActionsHintSeen,
        brightness: brightness ?? this.brightness,
        contrast: contrast ?? this.contrast,
        locale: locale ?? this.locale,
        refreshInterval: refreshInterval ?? this.refreshInterval,
      );
}
