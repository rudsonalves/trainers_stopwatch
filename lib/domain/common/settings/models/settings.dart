import '/core/result/result.dart';
import '../../training/values/distance.dart';

enum BrightnessPreference { light, dark }

enum ContrastPreference { standard, medium, high }

final class LanguagePreference {
  final String languageCode;
  final String? countryCode;

  const LanguagePreference(this.languageCode, [this.countryCode]);

  static const englishUnitedStates = LanguagePreference('en', 'US');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguagePreference &&
          languageCode == other.languageCode &&
          countryCode == other.countryCode;

  @override
  int get hashCode => Object.hash(languageCode, countryCode);
}

final class Settings {
  static final defaultSplitDistance = Distance.create(value: 200).value!;
  static final defaultLapDistance = Distance.create(value: 1000).value!;

  final int? id;
  final Distance splitDistance;
  final Distance lapDistance;
  final BrightnessPreference brightness;
  final ContrastPreference contrast;
  final LanguagePreference language;
  final Duration refreshInterval;
  final bool showTutorial;

  const Settings._({
    this.id,
    required this.splitDistance,
    required this.lapDistance,
    this.brightness = BrightnessPreference.dark,
    this.contrast = ContrastPreference.standard,
    this.language = LanguagePreference.englishUnitedStates,
    this.refreshInterval = const Duration(milliseconds: 66),
    this.showTutorial = true,
  });

  static Result<Settings> create({
    int? id,
    Distance? splitDistance,
    Distance? lapDistance,
    BrightnessPreference brightness = BrightnessPreference.dark,
    ContrastPreference contrast = ContrastPreference.standard,
    LanguagePreference language = LanguagePreference.englishUnitedStates,
    Duration refreshInterval = const Duration(milliseconds: 66),
    bool showTutorial = true,
  }) {
    final resolvedSplitDistance = splitDistance ?? defaultSplitDistance;
    final resolvedLapDistance = lapDistance ?? defaultLapDistance;

    if (resolvedSplitDistance.value == 0 || resolvedLapDistance.value == 0) {
      return const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Default training distances must be greater than zero.',
        ),
      );
    }

    if (resolvedSplitDistance.unit != resolvedLapDistance.unit) {
      return const Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Default training distances must use the same unit.',
        ),
      );
    }

    if (refreshInterval <= Duration.zero) {
      return Failure(
        AppError(
          code: AppErrorCode.invalidData,
          message: 'Refresh interval must be greater than zero.',
          details: refreshInterval,
        ),
      );
    }

    return Success(
      Settings._(
        id: id,
        splitDistance: resolvedSplitDistance,
        lapDistance: resolvedLapDistance,
        brightness: brightness,
        contrast: contrast,
        language: language,
        refreshInterval: refreshInterval,
        showTutorial: showTutorial,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Settings &&
          id == other.id &&
          splitDistance == other.splitDistance &&
          lapDistance == other.lapDistance &&
          brightness == other.brightness &&
          contrast == other.contrast &&
          language == other.language &&
          refreshInterval == other.refreshInterval &&
          showTutorial == other.showTutorial;

  @override
  int get hashCode => Object.hash(
        id,
        splitDistance,
        lapDistance,
        brightness,
        contrast,
        language,
        refreshInterval,
        showTutorial,
      );
}
