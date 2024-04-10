# Trainer's Stopwatch

The Trainer's Stopwatch app is ingeniously designed to harness the internal clock of the device for computing precise timings of training sessions, ensuring that any potential lags in the graphical interface do not affect its accuracy. This feature is crucial for trainers and coaches who rely on precise timing to assess and improve the performance of their athletes.

The app is equipped with an intuitive set of buttons to control the stopwatch, each serving a specific function in the training process:
- **Start/Continue**: Initiates or continues the timing, making it simple to kick off a training session or pick up where you left off.
- **Pause**: Temporarily halts the timing, allowing for breaks or interruptions without losing progress.
- **Reset**: Stops and resets the stopwatch and the lap counter, preparing it for a new session.
- **Lap**: A lap counter button that logs the time, useful for tracking performance over repetitive exercises or distances.
- **Split**: Captures a split time without stopping the stopwatch, perfect for recording the duration of individual activities within a continuous session.

Each athlete's timing data is meticulously recorded in an individual history log, enabling trainers to analyze performance over time and tailor training regimens accordingly.

To maintain a clean and user-friendly interface, the app smartly makes only the relevant buttons active based on the current state of the stopwatch:
- **StopwatchStateInitial**: Only the Start/Continue and Reset buttons are active, readying the app for initiation.
- **StopwatchStateRunning**: The Split, Pause, and Lap buttons become available, allowing for dynamic interaction during the session.
- **StopwatchStatePaused**: The interface reverts to offering the Start/Continue and Reset options, facilitating a smooth transition out of a paused state.

This thoughtful design ensures that the user interface remains uncluttered and focused, reducing confusion and enhancing the overall user experience. The Trainers Stopwatch is not just a timing tool; it's a comprehensive solution aimed at optimizing training efficiency and athlete performance through precision, convenience, and detailed analysis.

# ChangeLog

## 2024-04-10 - version: 0.4.2+5

Significant enhancements and refinements have been implemented in the Trainers Stopwatch app:

- **StopwatchBloc Enhancements**:
  - Transitioned from `ValueNotifier` to `Signal` for a more streamlined and elegant approach.
  - Removed `splitDuration` and `counterDuration` as they were deemed unnecessary.
  - The `_stopEvent` method has been optimized and simplified, ensuring accurate stop timing and lap counter adjustments.
  - Updated the display time in the `_pauseEvent` method for a more precise presentation of the pause moment.

- **Font Style Consolidation**:
  - All font styles are now centralized within the `AppFontStyle` class, promoting consistency and ease of maintenance.

- **Athlete Dialog and Tile Updates**:
  - Athlete images are now handled through `Signal`, enhancing the reactivity and update efficiency.
  - Athlete images are displayed using the `ShowAthleteImage` class, standardizing image presentation.
  - Modified `DismissibleAthleteTile` to use a `Signal` for athlete selection (`isChecked` signal).

- **Stopwatch Page and Controller Logic**:
  - Relocated PreciseTimer allocation logic for athletes to `StopwatchPageController`, streamlining the control mechanism.

- **Dismissible Background Enhancements**:
  - `DismissibleContainers` now accept `context`, `label`, `iconData`, and `color` parameters, offering customizable backgrounds.
  - Implemented an `enable` property for conditional rendering and interaction.

- **Precise Stopwatch Adjustments**:
  - Adapted the component to utilize `Signal` instead of `ValueNotifier`, refining the reactive functionality.
  - Renamed `PreciseTimer` to `PreciseStopwatch`, aligning the naming with its specific functionality.

These updates mark a significant improvement in the app’s functionality and user experience, introducing a more responsive and user-friendly interface, and refining the stopwatch logic for better performance and accuracy.


## 2024-04-09 - version: 0.4.1+3

Significant updates and enhancements have been made in the Trainers Stopwatch app, moving closer to a comprehensive professional solution for trainers. Here's a rundown of the latest improvements:

- **StopwatchBloc and Events**: The StopwatchBloc is now fully functional, implementing all events successfully. A few areas marked with FIXME need refinement for cleaner operation.

- **Common Constants**: Introduced a `constants.dart` file for app-wide constants, including `photoImageSize` for image sizing and `defaultPhotoImage` providing a default athlete image string.

- **Custom Icons**: Added a new set of custom icons specific to the app, enhancing the visual appeal and user experience.

- **App Settings Singleton**: Implemented the `AppSettings` singleton class to store system-wide variables like `imagePath`, organizing internal storage for athlete images.

- **Database and Settings Initialization**: The main entry point now includes database and app settings initialization, laying a solid foundation for the app's data handling.

- **Athlete Manager**: The `AthleteManager` class is introduced for comprehensive management of athlete-related operations, handling the business logic for athlete actions such as registration, editing, and deletion.

- **Data Models**: Data models for athletes, training sessions, and history are fully integrated with the store and repository layers, though currently, only athlete models are worked on within the manager layer.

- **Page Routing**: Routing for `StopWatchPage` and `AthletesPage` is set up, facilitating navigation within the app.

- **Repository Layer**: The repository layer is now fully implemented for athletes, history, and training, performing basic database operations and bridging app objects to database maps.

- **Athlete Dialog UI**: A new `AthleteDialog` class introduces a dialog for adding new athletes, complemented by `AthleteController` for handling form UI elements and `Validator` for input validation. A custom `TextField` widget is designed specifically for this dialog.

- **Athletes Page for Management**: The `AthletesPage` allows for athlete management within the app, with current functionality for adding new athletes. Future updates will include editing and removal options.

- **Dismissible Athlete Tile**: Customized Dismissible widget for athlete management in `AthletesPage`.

- **Stopwatch Page Adjustments**: Adjusted to display stopwatches for selected athletes from `AthletesPage`.

- **Database Store and Management**: Implemented insertion, update, deletion, and search methods across all app models. Additionally, constants for table names, attributes, and SQL creation scripts are defined, alongside static classes for database table creation and a `DatabaseManager` for overall database management.

- **Dependencies Update**: The `pubspec.yaml` file has been updated with packages for SQLite database (`sqflite`), file path extraction (`path_provider` and `path`), testing mocks (`mockito`), Observer pattern implementation (`signals`), and device camera access (`image_picker`). Also, added the custom `StopwatchIcons` font.

This version marks a significant step towards realizing a robust, professional stopwatch application tailored for trainers managing multiple athletes, combining precise timing functionalities with comprehensive athlete management and history tracking capabilities.


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
