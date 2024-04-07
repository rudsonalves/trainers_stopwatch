# stopwatch



# ChangeLog

## 2024_04_07 - version: 0.1.0:

### Enhancements in Stopwatch Functionality:
- **lib/bloc/stopwatch_bloc.dart** & **lib/bloc/stopwatch_events.dart**:
  - Introduced `StopwatchBloc` featuring:
    - A `ValueNotifier<Duration> _elapsed` initialized with `const Duration()` to log the stopwatch display refreshes.
    - A `ValueNotifier<int> _counter` initialized with `0` to log the stopwatch snapshots.
    - A `static int millisecondRefresh` set to `66` as a default value, managing the refresh rate of stopwatches at approximately 15FPS, enhancing the user experience with smoother transitions.
    - Implemented a `dispose` method to dispose of `_elapsed` and `_counter`, and to stop the `_timer`, ensuring resource efficiency and app stability.
  - Implemented events for comprehensive stopwatch control:
    - `StopwatchEventRun`
    - `StopwatchEventPause`
    - `StopwatchEventReset`
    - `StopwatchEventCounterIncrement`
    - `StopwatchEventCounterDecrement`
    - `StopwatchEventCounterReset`

### State Management:
- **lib/bloc/stopwatch_state.dart**:
  - Implemented states for precise stopwatch management, enhancing the user interface responsiveness and accuracy:
    - `StopwatchStateInitial`
    - `StopwatchStateRunning`
    - `StopwatchStatePaused`
    - `StopwatchStateReset`
    - `StopwatchStateError`

### UI Components and Integration:
- **lib/screens/stopwatch_page/stopwatch_page.dart**:
  - Each `PreciseTimer` is now integrated with an instance of `StopwatchBloc`, streamlining the stopwatch functionality and providing a more robust and flexible solution for timing needs.
- **lib/screens/widgets/common/custom_icon_button.dart**:
  - Added `CustomIconButton`, similar to an `IconButton` but with support for `onLongPressed`, offering extended functionality for user interactions.
- **lib/screens/widgets/precise_timer/precise_timer.dart**:
  - Business logic has been migrated to `StopwatchBloc`, centralizing the stopwatch's logic and facilitating easier maintenance and updates.

### Release Notes:
This update introduces a comprehensive overhaul of the stopwatch functionality within the Trainers Stopwatch app, aiming to provide coaches and trainers with a more precise and user-friendly timing tool. By optimizing the refresh rate and integrating robust state management, the app now offers enhanced performance and reliability, ensuring that timing is accurate and responsive to the trainers' needs.
