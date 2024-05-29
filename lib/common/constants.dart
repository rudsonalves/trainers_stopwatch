import 'dart:ui';

const photoImageSize = 80.0;
const defaultPhotoImage = 'assets/images/person.png';

const double elevationDisable = 0;
const double elevationEnable = 5;

const millisecondRefreshValues = [10, 33, 66, 133, 266, 500];

const distanceUnits = ['m', 'km', 'yd', 'mi'];
const speedUnits = ['m/s', 'km/h', 'yd/s', 'mph'];
const speedAllowedValues = {
  'm': ['m/s', 'km/h'],
  'km': ['m/s', 'km/h'],
  'yd': ['yd/s', 'm/s', 'mph'],
  'mi': ['yd/s', 'm/s', 'mph'],
};

class AppLanguage {
  final String language;
  final String flag;
  final Locale locale;

  const AppLanguage({
    required this.language,
    required this.flag,
    required this.locale,
  });

  String get localeCode => '${locale.languageCode}_${locale.countryCode}';
}

const Map<String, AppLanguage> appLanguages = {
  'pt_BR': AppLanguage(
    language: 'Português Brasil',
    flag: '🇧🇷',
    locale: Locale('pt', 'BR'),
  ),
  'es': AppLanguage(
    language: 'Español',
    flag: '🇪🇸',
    locale: Locale('es'),
  ),
  'en_US': AppLanguage(
    language: 'US English',
    flag: '🇺🇸',
    locale: Locale('en', 'US'),
  ),
};
