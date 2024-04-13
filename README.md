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

## 2024/03/13 - version: 0.7.1+7:

This release introduces several enhancements and new features aimed at refining the functionality and user experience of the Trainers Stopwatch app.

- **App Settings**:
  - Default values for `splitLength` and `lapLength` added to `AppSettings`.

- **Training Model Updates**:
  - `splitLength` and `lapLength` attributes are now non-nullable.
  - Introduced `distanceUnit` and `speedUnit` attributes to store units for distance and speed respectively.
  - Default values set for `splitLength` and `lapLength` are 200 and 1000, respectively.

- **Navigation and Routing**:
  - Routing added for `PersonalTrainingPage` using the method `PersonalTrainingPage.fromContext(context)`.

- **New Page: PersonalTrainingPage**:
  - This new page receives a clone of the selected stopwatch and displays current training records.

- **Stopwatch Page Enhancements**:
  - Implemented a temporary solution using `showSnackBar` to display ongoing training results; further refinement is needed.
  - Configured `DismissDirection.startToEnd` to launch `PersonalTrainingPage`, identified a bug with stopwatch restart that needs assessment.

- **Stopwatch Page Controller**:
  - Renamed `_selectedAthletes` to `_stopwatchList` and introduced `_stopwatchControllers`.
  - Added method `sendSnackBarMessage` to relay messages via `Signal<String> snackBarMessage`.

- **Set Distance Dialog Enhancement**:
  - Enhanced `SetDistancesDialog` to enable editing of `distanceUnit` and `speedUnit`.

- **Precise Stopwatch Modifications**:
  - `PreciseStopwatch` now takes `PreciseStopwatchController` as a parameter to facilitate cloning on `PersonalTrainingPage`.
  - Added `isNotClone` attribute to determine if the instance is a clone, affecting initialization and disposal behaviors.
  - Removed the bottom message line, transitioning to use `SnackBar` for messages.

- **Precise Stopwatch Controller Enhancements**:
  - Introduced `splitLength` and `lapLength` attributes.
  - Added `_actionOnPress` as a `ValueNotifier<bool>` (to be converted to `Signal<bool>` after resolving pending issues).
  - Implemented disposal for `ValueNotifier` and `Signal` objects: `counter`, `durationTraining`, and `_actionOnPress`.
  - Added `_toggleActionOnPress` method to toggle the state of `_actionOnPress`, used for activating the refresh of history on `PersonalTrainingPage`.
  - Method added for updating `splitLength` and `lapLength`.
  - Implemented `speedCalc` method to calculate speed in m/s and convert it to the unit selected by the user.

- **Database Schema Updates**:
  - Declared constants `trainingDistanceUnit` and `trainingSpeedUnit` for new columns in the `trainingsTable`.
  - Updated SQL script `createTrainingTableSQL` to make `trainingSplitLength` and `trainingLapLength` columns non-nullable and add new columns `trainingDistanceUnit` and `trainingSpeedUnit` (both CHAR(5)).

- **Dependencies**:
  - Added `intl` package for date formatting.

This update aims to streamline the user experience by integrating more precise controls and settings, enhancing the training management capabilities of the app.


## 2024-04-11 - version: 0.7.0+6:

This update introduces a series of enhancements and structural changes across the Trainers Stopwatch app to improve functionality and user experience:

- **StopwatchBloc Updates**:
  - Removed time interval calculation elements from `StopwatchBloc`. These are now handled by a new controller designed to manage the Stopwatch widget, streamlining the bloc's responsibilities.

- **App Settings Enhancements**:
  - Introduced `millisecondRefresh` control within the app settings to allow for configuration adjustments.
  - Added theme mode controls for `ThemeMode.light` and `ThemeMode.dark`, enhancing user customization options.

- **Font Style Additions**:
  - New styles have been added to `AppFontStyle` to support diverse UI requirements.

- **Manager Updates**:
  - Standardized error messages within `AthleteManager`.
  - Launched `HistoryManager` to oversee training history models.
  - Introduced `TrainingManager` to manage athlete training models.

- **Model Enhancements**:
  - `TrainingModel` now includes attributes to store the lengths of splits and laps, adding detailed tracking capabilities.

- **MyMaterialApp**:
  - Implemented theme selection support within the app for enhanced user personalization.

- **Athlete Dialog Adjustments**:
  - Modified the athlete dialog for both adding and updating athlete details, improving usability.

- **Athletes Page Enhancements**:
  - Added editing and removal capabilities for athletes on the `AthletesPage`, enhancing management efficiency.

- **Athletes Page Controller**:
  - Integrated methods to update and delete athletes, supporting robust athlete management.

- **Dismissible Athlete Tile**:
  - Introduced `editFunction` and `deleteFunction` callbacks to facilitate athlete management directly from the UI.

- **Stopwatch Page Updates**:
  - Added an `IconButton` for theme switching and another for setup (the latter is not yet implemented), improving accessibility and customization.

- **CustomIconButton Enhancements**:
  - `CustomIconButton` is now theme-reactive, adjusting its color scheme to better highlight its features and align with Android standards.

- **Generic Dialog Introduction**:
  - Deployed a generic dialog with predefined properties for various dialog actions (yesNo, addCancel, close, none), simplifying UI interactions.

- **Numeric Field Widget**:
  - Introduced `NumericField`, a widget similar to `TextField` but only accepts valid numbers, ensuring input accuracy.

- **Set Distance Dialog**:
  - Added a specialized dialog for setting distances for a split and lap, aiding in precise training setup.

- **Show Athlete Image Updates**:
  - Modified to accept an optional window size parameter, enhancing flexibility in image presentation.

- **Precise Stopwatch Updates**:
  - Removed `StopwatchBloc` from `PreciseStopwatch`. The bloc is now instantiated in the `PreciseStopwatchController`, centralizing all stopwatch control logic in the controller.
  - Adjusted layout to accommodate a text line displaying information on splits and laps when recorded.

- **Precise Stopwatch Controller**:
  - Created `PreciseStopwatchController` to handle business logic for `PreciseStopwatch`, encompassing all control logic previously in `StopwatchBloc` and adding split and lap record management.

These updates significantly enhance the app's configurability, user interaction, and overall efficiency, providing a more tailored and professional experience for trainers managing multiple athletes.


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
