// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

import '../store/constants/migration_sql_scripts.dart';

class SettingsModel {
  int? id;
  double splitLength;
  double lapLength;
  int dbSchemeVersion;
  ThemeMode theme;
  Locale language;
  int mSecondRefresh;

  SettingsModel({
    this.id,
    this.splitLength = 200,
    this.lapLength = 1000,
    this.dbSchemeVersion = MigrationSqlScripts.schemeVersion,
    this.theme = ThemeMode.system,
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
      'dbSchemeVersion': dbSchemeVersion,
      'theme': theme.name,
      'language': langCode,
      'mSecondRefresh': mSecondRefresh,
    };
  }

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    final themeName = map['theme'] as String;
    final langCodes = (map['language'] as String).split('_');
    final locale = langCodes.length < 2
        ? Locale(langCodes[0])
        : Locale(langCodes[0], langCodes[1]);

    return SettingsModel(
      id: map['id'] as int?,
      splitLength: map['splitLength'] as double? ?? 200.0,
      lapLength: map['lapLength'] as double? ?? 1000.0,
      dbSchemeVersion: map['dbSchemeVersion'] as int,
      theme: ThemeMode.values.firstWhere(
        (mode) => mode.name == themeName,
        orElse: () => ThemeMode.system,
      ),
      language: locale,
      mSecondRefresh: map['mSecondRefresh'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory SettingsModel.fromJson(String source) =>
      SettingsModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
