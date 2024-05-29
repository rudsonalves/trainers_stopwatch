import 'dart:convert';

import 'package:flutter/material.dart';

import '../store/constants/migration_sql_scripts.dart';

enum Contrast { standard, medium, high }

class SettingsModel {
  int? id;
  double splitLength;
  double lapLength;
  String lengthUnit;
  int dbSchemeVersion;
  Brightness brightness;
  Contrast contrast;
  Locale language;
  int mSecondRefresh;

  SettingsModel({
    this.id,
    this.splitLength = 200,
    this.lapLength = 1000,
    this.lengthUnit = 'm',
    this.dbSchemeVersion = MigrationSqlScripts.schemeVersion,
    this.brightness = Brightness.dark,
    this.contrast = Contrast.standard,
    this.language = const Locale('en', 'US'),
    this.mSecondRefresh = 66,
  });

  Map<String, dynamic> toMap() {
    final langCode =
        language.countryCode == null || language.countryCode!.isEmpty
            ? language.languageCode
            : '${language.languageCode}_${language.countryCode}';
    return <String, dynamic>{
      'id': id,
      'splitLength': splitLength,
      'lapLength': lapLength,
      'lengthUnit': lengthUnit,
      'dbSchemeVersion': dbSchemeVersion,
      'brightness': brightness.name,
      'contrast': contrast.name,
      'language': langCode,
      'mSecondRefresh': mSecondRefresh,
    };
  }

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    final brightnessName = map['brightness'] as String;
    final contrastName = (map['contrast'] ?? "standard") as String;
    final langCodes = (map['language'] as String).split('_');
    final locale = langCodes.length < 2
        ? Locale(langCodes[0])
        : Locale(langCodes[0], langCodes[1]);

    return SettingsModel(
      id: map['id'] as int?,
      splitLength: map['splitLength'] as double? ?? 200.0,
      lapLength: map['lapLength'] as double? ?? 1000.0,
      lengthUnit: map['lengthUnit'] as String? ?? 'm',
      dbSchemeVersion: map['dbSchemeVersion'] as int,
      brightness: Brightness.values.firstWhere(
        (mode) => mode.name == brightnessName,
        orElse: () => Brightness.dark,
      ),
      contrast: Contrast.values.firstWhere(
        (mode) => mode.name == contrastName,
        orElse: () => Contrast.standard,
      ),
      language: locale,
      mSecondRefresh: map['mSecondRefresh'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory SettingsModel.fromJson(String source) =>
      SettingsModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
