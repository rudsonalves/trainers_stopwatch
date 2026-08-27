class HistoryStatistics {
  final int persistedEntryCount;
  final int splitCount;
  final int lapCount;
  final Duration measuredDuration;
  final double measuredDistance;

  const HistoryStatistics({
    required this.persistedEntryCount,
    required this.splitCount,
    required this.lapCount,
    required this.measuredDuration,
    required this.measuredDistance,
  });

  static const empty = HistoryStatistics(
    persistedEntryCount: 0,
    splitCount: 0,
    lapCount: 0,
    measuredDuration: Duration.zero,
    measuredDistance: 0,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryStatistics &&
          persistedEntryCount == other.persistedEntryCount &&
          splitCount == other.splitCount &&
          lapCount == other.lapCount &&
          measuredDuration == other.measuredDuration &&
          measuredDistance == other.measuredDistance;

  @override
  int get hashCode => Object.hash(
        persistedEntryCount,
        splitCount,
        lapCount,
        measuredDuration,
        measuredDistance,
      );
}
