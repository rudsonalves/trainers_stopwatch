import '/core/result/result.dart';
import '/domain/common/settings/models/settings.dart';
import '/domain/common/training/units/distance_unit.dart';
import '/domain/common/training/values/distance.dart';
import '../database/table_attributes.dart';

final class SettingsMapper {
  const SettingsMapper();

  Result<Settings> fromMap(Map<String, Object?> map) {
    try {
      final unitResult = DistanceUnit.fromSymbol(
        map[settingsLengthUnit] as String? ?? DistanceUnit.meter.symbol,
      );
      if (unitResult.isFailure) return Failure(unitResult.error!);

      final splitResult = Distance.create(
        value: (map[settingsSplitLength] as num?)?.toDouble() ?? 200,
        unit: unitResult.value!,
      );
      if (splitResult.isFailure) return Failure(splitResult.error!);

      final lapResult = Distance.create(
        value: (map[settingsLapLength] as num?)?.toDouble() ?? 1000,
        unit: unitResult.value!,
      );
      if (lapResult.isFailure) return Failure(lapResult.error!);

      final languageParts =
          (map[settingsLanguage] as String? ?? 'en_US').split('_');
      return Settings.create(
        id: map[settingsId] as int?,
        splitDistance: splitResult.value!,
        lapDistance: lapResult.value!,
        brightness: map[settingsBrightness] == 'light'
            ? BrightnessPreference.light
            : BrightnessPreference.dark,
        contrast: switch (map[settingsContrast]) {
          'medium' => ContrastPreference.medium,
          'high' => ContrastPreference.high,
          _ => ContrastPreference.standard,
        },
        language: LanguagePreference(
          languageParts.first,
          languageParts.length > 1 ? languageParts[1] : null,
        ),
        refreshInterval: Duration(
          milliseconds: map[settingsMSecondRefresh] as int? ?? 66,
        ),
      );
    } catch (error, stackTrace) {
      return Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Invalid persisted settings data.',
          details: (error: error, stackTrace: stackTrace, data: map),
        ),
      );
    }
  }

  Map<String, Object?> toMap(Settings settings) {
    final countryCode = settings.language.countryCode;
    final language = countryCode == null || countryCode.isEmpty
        ? settings.language.languageCode
        : '${settings.language.languageCode}_$countryCode';

    return <String, Object?>{
      if (settings.id != null) settingsId: settings.id,
      settingsSplitLength: settings.splitDistance.value,
      settingsLapLength: settings.lapDistance.value,
      settingsLengthUnit: settings.splitDistance.unit.symbol,
      settingsBrightness: settings.brightness.name,
      settingsContrast: settings.contrast.name,
      settingsLanguage: language,
      settingsMSecondRefresh: settings.refreshInterval.inMilliseconds,
    };
  }
}
