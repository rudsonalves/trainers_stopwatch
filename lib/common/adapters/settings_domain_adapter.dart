import 'package:flutter/material.dart';

import '../../core/result/result.dart';
import '../../domain/common/settings/models/settings.dart' as domain;
import '../../domain/common/training/units/distance_unit.dart';
import '../../domain/common/training/values/distance.dart';
import '../models/settings_model.dart';

// Temporary legacy bridge. Remove after backlogs 005, 007 and 010 migrate the
// remaining AppSettings consumers.
extension SettingsModelDomainAdapter on SettingsModel {
  Result<domain.Settings> toDomain() {
    final parsedUnit = DistanceUnit.fromSymbol(lengthUnit);
    if (parsedUnit.isFailure) return Failure(parsedUnit.error!);

    final split = Distance.create(value: splitLength, unit: parsedUnit.value!);
    if (split.isFailure) return Failure(split.error!);

    final lap = Distance.create(value: lapLength, unit: parsedUnit.value!);
    if (lap.isFailure) return Failure(lap.error!);

    return domain.Settings.create(
      id: id,
      splitDistance: split.value!,
      lapDistance: lap.value!,
      brightness: brightness == Brightness.light
          ? domain.BrightnessPreference.light
          : domain.BrightnessPreference.dark,
      contrast: switch (contrast) {
        Contrast.standard => domain.ContrastPreference.standard,
        Contrast.medium => domain.ContrastPreference.medium,
        Contrast.high => domain.ContrastPreference.high,
      },
      language: domain.LanguagePreference(
        language.languageCode,
        language.countryCode,
      ),
      refreshInterval: Duration(milliseconds: mSecondRefresh),
    );
  }
}

extension SettingsLegacyAdapter on domain.Settings {
  SettingsModel toLegacy() => SettingsModel(
        id: id,
        splitLength: splitDistance.value,
        lapLength: lapDistance.value,
        lengthUnit: splitDistance.unit.symbol,
        brightness: brightness == domain.BrightnessPreference.light
            ? Brightness.light
            : Brightness.dark,
        contrast: switch (contrast) {
          domain.ContrastPreference.standard => Contrast.standard,
          domain.ContrastPreference.medium => Contrast.medium,
          domain.ContrastPreference.high => Contrast.high,
        },
        language: Locale(language.languageCode, language.countryCode),
        mSecondRefresh: refreshInterval.inMilliseconds,
      );
}
