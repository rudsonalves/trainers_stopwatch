import '/core/result/result.dart';

const defaultSpeedUnit = SpeedUnit.metersPerSecond;

enum SpeedUnit {
  metersPerSecond('m/s'),
  kilometersPerHour('km/h'),
  yardsPerSecond('yd/s'),
  milesPerHour('mph');

  final String symbol;

  const SpeedUnit(this.symbol);

  static Result<SpeedUnit> fromSymbol(String symbol) {
    for (final unit in values) {
      if (unit.symbol == symbol) return Success(unit);
    }

    return Failure(
      AppError(
        code: AppErrorCode.invalidData,
        message: 'Unknown speed unit.',
        details: symbol,
      ),
    );
  }

  double get fromMetersPerSecondFactor => switch (this) {
        SpeedUnit.metersPerSecond => 1,
        SpeedUnit.kilometersPerHour => 3.6,
        SpeedUnit.yardsPerSecond => 1.09361,
        SpeedUnit.milesPerHour => 2.23694,
      };
}
