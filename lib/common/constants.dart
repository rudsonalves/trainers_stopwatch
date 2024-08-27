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

import 'dart:ui';

const photoImageSize = 80.0;
const defaultPhotoImage = 'assets/images/person.png';
const usersImages = 'users_images';

const double elevationDisable = 0;
const double elevationEnable = 5;

const millisecondRefreshValues = [10, 33, 66, 133, 266, 500];

const primaryColor = Color(0xff4a5c92);

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
