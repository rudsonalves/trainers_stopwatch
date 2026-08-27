import 'dart:ui';

import 'package:flutter/foundation.dart';

import '/domain/common/settings/models/settings.dart';

enum AppContrast { standard, medium, high }

/// Global presentation state that affects the application root.
///
/// Persistence and operation state belong to the settings repository and page
/// ViewModel. This object deliberately keeps only the values required to
/// rebuild the application theme and locale.
class AppAppearanceState extends ChangeNotifier {
  Brightness _brightness;
  AppContrast _contrast;
  Locale _locale;

  AppAppearanceState({required Settings settings})
      : _brightness = _brightnessFrom(settings.brightness),
        _contrast = _contrastFrom(settings.contrast),
        _locale = _localeFrom(settings.language);

  Brightness get brightness => _brightness;
  AppContrast get contrast => _contrast;
  Locale get locale => _locale;

  void synchronize(Settings settings) {
    update(
      brightness: _brightnessFrom(settings.brightness),
      contrast: _contrastFrom(settings.contrast),
      locale: _localeFrom(settings.language),
    );
  }

  void update({
    Brightness? brightness,
    AppContrast? contrast,
    Locale? locale,
  }) {
    final nextBrightness = brightness ?? _brightness;
    final nextContrast = contrast ?? _contrast;
    final nextLocale = locale ?? _locale;

    if (nextBrightness == _brightness &&
        nextContrast == _contrast &&
        nextLocale == _locale) {
      return;
    }

    _brightness = nextBrightness;
    _contrast = nextContrast;
    _locale = nextLocale;
    notifyListeners();
  }

  static Brightness _brightnessFrom(BrightnessPreference brightness) =>
      switch (brightness) {
        BrightnessPreference.light => Brightness.light,
        BrightnessPreference.dark => Brightness.dark,
      };

  static AppContrast _contrastFrom(ContrastPreference contrast) =>
      switch (contrast) {
        ContrastPreference.standard => AppContrast.standard,
        ContrastPreference.medium => AppContrast.medium,
        ContrastPreference.high => AppContrast.high,
      };

  static Locale _localeFrom(LanguagePreference language) =>
      Locale(language.languageCode, language.countryCode);
}
