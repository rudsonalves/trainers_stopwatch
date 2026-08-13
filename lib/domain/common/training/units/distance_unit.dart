import '/core/result/result.dart';

const defaultDistanceUnit = DistanceUnit.meter;

enum DistanceUnit {
  meter('m'),
  kilometer('km'),
  yard('yd'),
  mile('mi');

  final String symbol;

  const DistanceUnit(this.symbol);

  static Result<DistanceUnit> fromSymbol(String symbol) {
    for (final unit in values) {
      if (unit.symbol == symbol) return Success(unit);
    }

    return Failure(
      AppError(
        code: AppErrorCode.invalidData,
        message: 'Unknown distance unit.',
        details: symbol,
      ),
    );
  }

  double get metersFactor => switch (this) {
        DistanceUnit.meter => 1,
        DistanceUnit.kilometer => 1000,
        DistanceUnit.yard => 0.9144,
        DistanceUnit.mile => 1609.34,
      };
}
