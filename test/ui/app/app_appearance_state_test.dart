import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/domain/common/settings/models/settings.dart';
import 'package:trainers_stopwatch/ui/app/app_appearance_state.dart';

void main() {
  group('AppAppearanceState', () {
    test('initializes presentation state from domain settings', () {
      final settings = Settings.create(
        brightness: BrightnessPreference.light,
        contrast: ContrastPreference.high,
        language: const LanguagePreference('pt', 'BR'),
      ).value!;

      final viewModel = AppAppearanceState(settings: settings);
      addTearDown(viewModel.dispose);

      expect(viewModel.brightness, Brightness.light);
      expect(viewModel.contrast, AppContrast.high);
      expect(viewModel.locale, const Locale('pt', 'BR'));
    });

    test('updates all global values with a single notification', () {
      final viewModel = AppAppearanceState(
        settings: Settings.create().value!,
      );
      addTearDown(viewModel.dispose);
      var notifications = 0;
      viewModel.addListener(() => notifications++);

      viewModel.update(
        brightness: Brightness.light,
        contrast: AppContrast.medium,
        locale: const Locale('es'),
      );

      expect(viewModel.brightness, Brightness.light);
      expect(viewModel.contrast, AppContrast.medium);
      expect(viewModel.locale, const Locale('es'));
      expect(notifications, 1);
    });

    test('does not notify when presentation state remains unchanged', () {
      final settings = Settings.create().value!;
      final viewModel = AppAppearanceState(settings: settings);
      addTearDown(viewModel.dispose);
      var notifications = 0;
      viewModel.addListener(() => notifications++);

      viewModel.synchronize(settings);

      expect(notifications, 0);
    });

    test('synchronizes changed domain settings', () {
      final viewModel = AppAppearanceState(
        settings: Settings.create().value!,
      );
      addTearDown(viewModel.dispose);
      final changed = Settings.create(
        brightness: BrightnessPreference.light,
        contrast: ContrastPreference.medium,
        language: const LanguagePreference('es'),
      ).value!;

      viewModel.synchronize(changed);

      expect(viewModel.brightness, Brightness.light);
      expect(viewModel.contrast, AppContrast.medium);
      expect(viewModel.locale, const Locale('es'));
    });
  });
}
