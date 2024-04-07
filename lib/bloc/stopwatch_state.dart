abstract class StopwatchState {}

class StopwatchStateInitial extends StopwatchState {}

class StopwatchStateRunning extends StopwatchState {}

class StopwatchStatePaused extends StopwatchState {}

class StopwatchStateReset extends StopwatchState {}

class StopwatchStateError extends StopwatchState {
  final String message;
  StopwatchStateError(this.message);
}
