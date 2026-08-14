import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/errors/app_error_code.dart';
import 'package:trainers_stopwatch/domain/common/settings/models/settings.dart';
import 'package:trainers_stopwatch/domain/common/training/units/distance_unit.dart';
import 'package:trainers_stopwatch/domain/common/training/values/distance.dart';
import 'package:trainers_stopwatch/ui/app/app_appearance_state.dart';
import 'package:trainers_stopwatch/ui/pages/settings/models/settings_form_data.dart';

void main() {
  test('converts every settings value between domain and UI', () {
    final settings = Settings.create(
      id: 7,
      splitDistance: Distance.create(
        value: 220,
        unit: DistanceUnit.yard,
      ).value!,
      lapDistance: Distance.create(
        value: 1100,
        unit: DistanceUnit.yard,
      ).value!,
      brightness: BrightnessPreference.light,
      contrast: ContrastPreference.high,
      language: const LanguagePreference('pt', 'BR'),
      refreshInterval: const Duration(milliseconds: 100),
    ).value!;

    final form = SettingsFormData.fromDomain(settings);
    final converted = form.toDomain();

    expect(form.id, 7);
    expect(form.splitDistance, 220);
    expect(form.lapDistance, 1100);
    expect(form.distanceUnit, DistanceUnit.yard);
    expect(form.brightness, Brightness.light);
    expect(form.contrast, AppContrast.high);
    expect(form.locale, const Locale('pt', 'BR'));
    expect(form.refreshInterval, const Duration(milliseconds: 100));
    expect(converted.value, settings);
  });

  test('rejects invalid form data before it reaches persistence', () {
    final form = SettingsFormData.fromDomain(Settings.create(id: 1).value!);

    final converted = form.copyWith(lapDistance: 0).toDomain();

    expect(converted.isFailure, isTrue);
    expect(converted.error!.code, AppErrorCode.invalidData);
  });
}
