abstract class StopwatchEvent {
  const StopwatchEvent();
}

final class StopwatchEventRun extends StopwatchEvent {
  const StopwatchEventRun();
}

final class StopwatchEventPause extends StopwatchEvent {
  const StopwatchEventPause();
}

final class StopwatchEventResume extends StopwatchEvent {
  const StopwatchEventResume();
}

final class StopwatchEventReset extends StopwatchEvent {
  const StopwatchEventReset();
}

final class StopwatchEventSplit extends StopwatchEvent {
  const StopwatchEventSplit();
}

final class StopwatchEventLap extends StopwatchEvent {
  const StopwatchEventLap();
}

final class StopwatchEventStop extends StopwatchEvent {
  const StopwatchEventStop();
}

final class StopwatchEventConfigure extends StopwatchEvent {
  final int? maxLaps;
  final int splitsPerLap;

  const StopwatchEventConfigure({
    required this.maxLaps,
    required this.splitsPerLap,
  });
}
