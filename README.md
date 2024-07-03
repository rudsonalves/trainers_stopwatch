# Trainer's Stopwatch

The Trainer's Stopwatch app is ingeniously designed to harness the internal clock of the device for computing precise timings of training sessions, ensuring that any potential lags in the graphical interface do not affect its accuracy. This feature is crucial for trainers and coaches who rely on precise timing to assess and improve the performance of their users.

The app is equipped with an intuitive set of buttons to control the stopwatch, each serving a specific function in the training process:
- **Start/Continue**: Initiates or continues the timing, making it simple to kick off a training session or pick up where you left off.
- **Pause**: Temporarily halts the timing, allowing for breaks or interruptions without losing progress.
- **Reset**: Stops and resets the stopwatch and the lap counter, preparing it for a new session.
- **Lap**: A lap counter button that logs the time, useful for tracking performance over repetitive exercises or distances.
- **Split**: Captures a split time without stopping the stopwatch, perfect for recording the duration of individual activities within a continuous session.

Each user's timing data is meticulously recorded in an individual history log, enabling trainers to analyze performance over time and tailor training regimens accordingly.

To maintain a clean and user-friendly interface, the app smartly makes only the relevant buttons active based on the current state of the stopwatch:
- **StopwatchStateInitial**: Only the Start/Continue and Reset buttons are active, readying the app for initiation.
- **StopwatchStateRunning**: The Split, Pause, and Lap buttons become available, allowing for dynamic interaction during the session.
- **StopwatchStatePaused**: The interface reverts to offering the Start/Continue and Reset options, facilitating a smooth transition out of a paused state.

This thoughtful design ensures that the user interface remains uncluttered and focused, reducing confusion and enhancing the overall user experience. The Trainers Stopwatch is not just a timing tool; it's a comprehensive solution aimed at optimizing training efficiency and user performance through precision, convenience, and detailed analysis.

# ChangeLog

## 2024_07_03 - version: 1.0.0+33

refactor: Update HistoryModel usage and refactor history management

- Refactored `updateHistory` method across various controllers to use `HistoryModel` instead of `int historyId`.
- Updated `MessagesModel` to include `historyId` in `toString()` method.
- Commented out unused `isSplit` case in `MessagesModel`.
- Adjusted `StopwatchDrawer` to align the text at the bottom center.
- Renamed `managerUpdate` to `editHistory` in `DismissibleHistory` and related calls.
- Added `editHistory` method to `HistoryListView` to handle history edits through a dialog.
- Commented out the unused `_cleanUserLog` method in `PreciseStopwatch`.
- Updated `PreciseStopwatchController` to use `HistoryModel` for updating history.
- Added `getById` method to `HistoryManager` for fetching a history by ID.
- Refactored `update` method in `HistoryManager` to use `HistoryModel` directly.
- Renamed `query` to `getById` in `AbstractHistoryRepository` and `HistoryRepository` for consistency.

### Detailed Description:

1. **History Management Refactor:**
   - Changed the signature of the `updateHistory` method in various controllers (`HistoryPageController`, `PersonalTrainingController`, `PreciseStopwatchController`) to accept `HistoryModel` instead of an integer ID. This change ensures that the entire history object is passed, allowing for more detailed updates and better type safety.
   
2. **Model Updates:**
   - Updated `MessagesModel` to include `historyId` in the `toString()` method for better debugging and logging.
   - Commented out the `isSplit` case in the `MessagesModel` class, indicating that it is currently not in use.

3. **UI Adjustments:**
   - Modified `StopwatchDrawer` to align the text at the bottom center, enhancing the UI layout and readability.

4. **Dismissible History:**
   - Renamed the `managerUpdate` function to `editHistory` in the `DismissibleHistory` widget and ensured that related calls in the widget tree were updated accordingly.
   - Added `editHistory` method in `HistoryListView` to handle the editing of history entries through a dialog interface, providing a more interactive user experience.

5. **Precise Stopwatch:**
   - Commented out the `_cleanUserLog` method in `PreciseStopwatch`, indicating it is not in use and simplifying the codebase.

6. **HistoryManager and Repository:**
   - Introduced the `getById` method in `HistoryManager` to fetch a history record by its ID, improving data retrieval capabilities.
   - Refactored the `update` method in `HistoryManager` to accept `HistoryModel` directly, simplifying the update logic and ensuring consistency.
   - Renamed the `query` method to `getById` in both `AbstractHistoryRepository` and `HistoryRepository` for better clarity and consistency in naming conventions.

These changes collectively improve the structure, readability, and maintainability of the codebase, ensuring that history management is more robust and that UI components are better aligned.


## 2024_07_03 - version: 1.0.0+32

feat: Implementation of WhatsApp data sending button and enhancements in training management interface

- Added "WhatsApp" button for sending data through the app.
- Included green-colored WhatsApp icon.
- Added `IconButton` for removing selected trainings, with updated focus and tooltip.
- Adjusted logic for selecting and deselecting all trainings.
- Removed `lap` and `split` columns from the `historyTable`.
- Updated SQL scripts for creating and handling the `historyTable`.
- Updated `pubspec.yaml` file to version `1.0.0+32`.

**Detailed Description:**

This commit introduces several significant enhancements to the Trainer’s Stopwatch application, aimed at improving user experience and functionality. The primary focus is on integrating a new feature for sending data via WhatsApp and refining the training management interface. These changes ensure that trainers and athletes can efficiently manage and share their training data, leading to a more streamlined and user-friendly experience.

**WhatsApp Data Sending Functionality:**

- **New Button Implementation:**
  - A "WhatsApp" button has been added to the application interface, enabling users to send their training data directly through WhatsApp.
  - This button features a green-colored WhatsApp icon followed by the text "WhatsApp" for clear identification.

**Enhancements in Training Management Interface:**

- **Removal Button for Selected Trainings:**
  - An `IconButton` has been introduced to allow users to remove selected trainings. This button is equipped with a tooltip 'GenericRemove' and only activates when there are selected trainings.
  - The button has updated focus management to improve accessibility.

- **Selection and Deselection Logic:**
  - The logic for selecting and deselecting all trainings has been refined. The button for selecting/deselecting all trainings now correctly handles states based on whether trainings are present and selected.

**Database Schema Updates:**

- **Column Removal:**
  - The `lap` and `split` columns have been removed from the `historyTable`. This change simplifies the database schema and aligns with the streamlined data management approach.
  
- **SQL Script Adjustments:**
  - Corresponding SQL scripts for creating and managing the `historyTable` have been updated to reflect the removal of the `lap` and `split` columns.

**Project Version Update:**

- **Version Increment:**
  - The project's version has been updated from `0.9.10+31` to `1.0.0+32` in the `pubspec.yaml` file, indicating a significant update with new features and enhancements.

These updates enhance the functionality and usability of the Trainer’s Stopwatch application, making it more efficient for managing and sharing training data.


## 2024_06_13 - version: 0.9.10+31

Release First Beta Version with Comprehensive Enhancements and Optimizations

**Detailed Changes:**

- **Build PDF Functionality**:
  - Added `makeReport` method to generate detailed training reports for users, including metrics like total length, total time, medium speed, lap length, split length, and number of laps.
  - Enhanced PDF formatting with the inclusion of user details and training logs.

- **Share Functionality**:
  - Updated `sendWhatsApp` and `sendEmail` methods to utilize the new `makeReport` method for generating comprehensive PDF reports.
  - Included user details in shared reports for better personalization.

- **Stopwatch Functions**:
  - Introduced `SpeedValue` class to encapsulate speed and its unit, ensuring consistent handling and display of speed metrics across the application.
  - Enhanced `formatDuration` method to handle durations exceeding one hour, ensuring accurate time representation.

- **Training Report Enhancements**:
  - Streamlined `TrainingReport` class by removing redundant methods and focusing on generating message models with detailed training information.
  - Improved message creation methods to include user names and formatted speed values, providing clearer and more informative messages.

- **Messages Model**:
  - Added new fields (`userName`, `label`, `speed`, `duration`, `comments`) to the `MessagesModel` class for detailed message representation.
  - Implemented methods to generate formatted titles and subtitles for message logs, ensuring clarity in the displayed and logged messages.

- **History Page Controller**:
  - Updated state management to handle the new speed calculation and message generation functionalities.
  - Ensured proper logging and error handling during history retrieval and updates.

- **Trainings Page**:
  - Enhanced sharing functionality to include user details in shared training logs.
  - Removed redundant report generation code, focusing on streamlined sharing methods.

- **Dismissible History Widget**:
  - Improved display of history messages with detailed subtitles, including speed values and formatted durations.
  - Added handling for finish messages with appropriate icons and labels.

- **Precise Stopwatch Controller**:
  - Updated message generation methods to include detailed labels, speed values, and durations for split and lap messages.
  - Enhanced finish message generation with formatted timestamps and clear labels.

- **Project Configuration**:
  - Updated project version to `0.9.9+30` in `pubspec.yaml` to reflect the transition to the first beta release.

These enhancements mark the completion of all planned features and improvements for the application, moving it into the beta testing phase for final bug fixes and optimizations before the first official release.


## 2024_06_13 - version: 0.9.9+30

Enhance PersonalTrainingController and HistoryListView with Improved State Management and Message Handling

**Detailed Changes:**

- **PersonalTrainingController**:
  - Improved `getHistory` method to handle errors and update the state accordingly.
  - Added `trainingReport.createMessages()` in `getHistory`, `updateHistory`, and `deleteHistory` methods to keep the messages updated based on the latest history changes.
  - Ensured state changes are correctly reflected in case of errors with appropriate logging.

- **TrainingsPageController**:
  - Added `_removeFromSelection` method to remove a training from the selection list upon deletion.
  - Integrated `_removeFromSelection` call within `removeTraining` to keep the selection list updated.

- **HistoryListView**:
  - Refactored to use messages model import for consistency.
  - Updated the `build` method to handle reversed message lists, ensuring correct display order.
  - Adjusted ListView builder to display the correct set of messages, taking into account the `reversed` flag for proper order presentation.

These changes aim to provide a more robust and user-friendly experience by ensuring state and message consistency across various parts of the application.


## 2024_06_12 - version: 0.9.8+29

This commit enhances the project with various improvements and new features that provide a more robust and efficient user experience. 

**Changes:**

- **Android Manifest Update**:
  - Enabled `android.intent.action.PROCESS_TEXT` intent filter to support text processing within the application.

- **History Controller Enhancements**:
  - Added `TrainingReport` integration to the `HistoryController`.
  - Updated the `init` method to initialize `TrainingReport` with user and training data, including histories.
  - Ensured that `getHistory` updates the training report messages upon fetching history data.

- **New Training Report Class**:
  - Created `TrainingReport` to handle the generation of training reports.
  - The class includes methods for creating split and lap messages, calculating speeds, and formatting durations.
  - Provides a structured way to log and retrieve training history details.

- **Messages Model Updates**:
  - Introduced `MessageType` enum to classify message types (Lap, Split, Starting).
  - Added `historyId` to `MessagesModel` to link messages with specific history records.

- **History Page Updates**:
  - Modified `init` method to accept user, training, and history data.
  - Initialized `TrainingReport` with the necessary data within the controller.
  - Updated `HistoryListView` to work with new messages from `TrainingReport`.

- **Personal Training Page Enhancements**:
  - Updated `PersonalTrainingController` to use the enhanced `HistoryController` with `TrainingReport`.
  - Initialized the controller with user, training, and history data.

- **Trainings Page Updates**:
  - Added functionality to generate detailed training reports.
  - Introduced a new icon in the action bar to trigger report generation.
  - Refactored the `SelectUserPopupMenu` into a separate widget for better code organization.

- **Widgets and UI Improvements**:
  - Refactored `DismissibleHistory` to work with the new `MessagesModel`.
  - Updated `HistoryListView` to display messages instead of direct history data.
  - Enhanced `PreciseStopwatch` UI for better alignment and presentation.

- **History Manager Enhancements**:
  - Added a `newInstance` method to `HistoryManager` for better initialization and fetching of history data.

This commit ensures a more structured approach to handling training data, improves user experience with new reporting capabilities, and enhances the overall maintainability and readability of the codebase.


## 2024_06_11 - version: 0.9.7+28

Enhanced app initialization, sharing features, and UI improvements

- **flutter_native_splash Configuration:**
  - Added `flutter_native_splash.yaml` to configure splash screens with primary and dark colors.
  - Set Android 12 splash screen image.

- **Icon Path Update:**
  - Changed icon path in `build_pdf.dart` from `assets/icon/stopwatch.png` to `assets/icons/stopwatch.png`.

- **Sharing Enhancements:**
  - Added `share_plus` package for sharing capabilities.
  - Implemented `sendWhatsApp` function in `share_functions.dart` to share training PDFs via WhatsApp.

- **UI Improvements:**
  - Increased `maxFocusNode` to 28 in `app_settings.dart`.
  - Adjusted button styles to `FilledButton.tonal` for a more consistent look across:
    - `stopwatch_overlay.dart`
    - `stopwatch_page.dart`
    - `edit_training_dialog.dart`
    - `users_overlay.dart`
    - `user_dialog.dart`
    - `generic_dialog.dart`
  - Ensured splash screen removal after app initialization in `stopwatch_page.dart` using `FlutterNativeSplash.remove()`.
  - Enhanced `edit_training_dialog.dart` to include animated updates of split and lap distances with added validation.

- **Refactoring and Cleanup:**
  - Renamed `TrainingsPage` to `TrainingsOverlay` and updated related navigation routes and tutorial overlays.
  - Introduced `SelectUserPopupMenu` component for better user selection in `trainings_page.dart`.
  - Enhanced `DismissibleHistory` to optionally disable delete functionality based on the `enableDelete` flag.
  - Added `onChanged` callback in `NumericField` for real-time updates.

- **Database Initialization Logging:**
  - Added logging statements in `database_manager.dart` to track table creation process.

- **Dependency and Version Updates:**
  - Updated `pubspec.yaml` to include:
    - `flutter_native_splash: ^2.4.0`
    - `share_plus: ^9.0.0`
  - Incremented app version to `0.9.7+28` to reflect new features and enhancements.


## 2024_06_07 - version: 0.9.6+27

Refactor and enhance history management:

This commit introduces several improvements and refactorings to the history management features of the application. Key changes include the creation of abstract classes for better state management, updates to the history and training controllers, and various UI enhancements.

- **New Abstract Classes**: Introduced `HistoryController` and related state classes to abstract history management logic.
  - Added `lib/common/abstract_classes/history_controller.dart`.

- **Version Update**: Incremented app version to `0.9.6+27`.
  - Updated `lib/common/app_info.dart` and `pubspec.yaml`.

- **Refactored History Page**:
  - Moved history list view logic to a separate widget `HistoryListView`.
  - Moved training information display logic to a new widget `TrainingInformations`.
  - Updated `HistoryPage` to use the new abstract classes and widgets.
  - Deleted `lib/features/history_page/history_page_state.dart`.

- **Controller Enhancements**:
  - Refactored `HistoryPageController` to extend the new `HistoryController`.
  - Created `PersonalTrainingController` to manage personal training sessions.
  - Updated `PersonalTrainingPage` to use `PersonalTrainingController`.

- **UI Improvements**:
  - Enhanced `MessageRow` to correctly reverse the message list in `StopWatchPage`.

- **Removed Redundant Imports**:
  - Cleaned up imports in various files to remove unused dependencies.

These changes aim to streamline history management, improve code maintainability, and enhance the user interface for a better user experience.


## 2024_06_06 - version: 0.9.5+26

Refactor and updates to the project:

This commit introduces significant refactoring and updates across various components of the project. It includes enhancements in translation files, UI improvements, new functionality in stopwatch functions, and code clean-up. The changes aim to improve the maintainability and user experience of the application.

* **Updated translation files:**
  - Added new translation keys in `en-US.json`, `es.json`, and `pt-BR.json`.

* **Updated constants:**
  - Added `primaryColor` constant in `lib/common/constants.dart`.

* **Enhanced stopwatch functions:**
  - Added `formatDuration` function in `lib/common/functions/stopwatch_functions.dart`.

* **Improved font styles:**
  - Added `roboto10` style in `lib/common/theme/app_font_style.dart`.

* **Refactored history page:**
  - Replaced `CardHistory` with `DismissibleHistory` in `lib/features/history_page/history_page.dart`.

* **Updated controllers:**
  - Added `updateHistory` and `deleteHistory` methods to `HistoryPageController`.

* **Improved trainings page:**
  - Adjusted `trainings_page.dart` to reflect new control logic and color management.

* **Implemented new widget:**
  - Created `dismissible_history.dart` for managing history with edit and delete options.

* **Enhanced edit training dialog:**
  - Added color selection in `edit_training_dialog.dart` and created `color_dialog.dart`.

* **Updated models and repositories:**
  - Added a color field to `TrainingModel`.
  - Adjusted `history_repository.dart` to support updates without explicitly passing an ID.

* **Added new dependencies:**
  - Included `flutter_colorpicker` in `pubspec.yaml`.

* **Other improvements:**
  - General adjustments in layouts and widget behaviors for better usability and visual consistency.

The files `lib/features/history_page/widgets/card_history.dart` and `lib/features/personal_training_page/widgets/dismissible_personal_training.dart` were removed and replaced with `lib/features/widgets/common/dismissible_history.dart`.


## 2024_06_04 - version: 0.9.4+25

Introduced new features and made several improvements to the application.

Refactor AndroidManifest and Update Application Assets

- Updated `AndroidManifest.xml`:
  - Commented out `<intent>` element for `android.intent.action.PROCESS_TEXT`.
  - Added `<intent>` element for `android.intent.action.SENDTO` with `mailto` scheme.

- Replaced launcher icons in various resolutions:
  - `mipmap-hdpi/ic_launcher.png`
  - `mipmap-mdpi/ic_launcher.png`
  - `mipmap-xhdpi/ic_launcher.png`
  - `mipmap-xxhdpi/ic_launcher.png`
  - `mipmap-xxxhdpi/ic_launcher.png`

- Added new asset icons:
  - `assets/icons/stopwatch.png`
  - `assets/svgs/stopwatch2.svg`

- Updated translations to include "Share" feature:
  - `assets/translations/en-US.json`
  - `assets/translations/es.json`
  - `assets/translations/pt-BR.json`

- Incremented app version from `0.9.3+22` to `0.9.3+24` in `lib/common/app_info.dart`.

- Added functionality to generate and share PDFs via email:
  - Created `lib/common/functions/build_pdf.dart` to build PDFs from training data.
  - Created `lib/common/functions/share_functions.dart` to handle email sending with attachment.

- Enhanced `history_page` to include training comments:
  - Modified `_cardHeader` in `lib/features/history_page/history_page.dart`.

- Improved training selection and sharing functionality:
  - Updated `lib/features/trainings_page/trainings_page.dart` to handle email sharing.
  - Enhanced `TrainingsPageController` to check if all trainings are selected.

- Improved UI components:
  - `SimpleSpinBoxField` in `lib/features/widgets/common/simple_spin_box_field.dart` to support nullable values.
  - `UserCard` in `lib/features/widgets/common/user_card.dart` to handle text overflow.
  - `EditTrainingDialog` in `lib/features/widgets/edit_training_dialog/edit_training_dialog.dart` to include comments.
  - `LapSplitCounters` in `lib/features/widgets/precise_stopwatch/widgets/lap_split_counters.dart` to dynamically display lap count.


## 2024_06_04 - version: 0.9.4+24

Replace Signal with ValueNotifier

Replaced the Signal package with ValueNotifier in several parts of the codebase to address issues encountered during development with hot-reload. It seems that Signal was masking dispose errors of some elements, causing interference with hot-reload. While not entirely certain, I decided to remove Signal and use ValueNotifier instead.

Changes Made:
- Updated lib/bloc/stopwatch_bloc.dart:
  - Replaced Signal with ValueNotifier for attributes _lapCounter and _splitCounter.
- Updated lib/common/singletons/app_settings.dart:
  - Replaced Signal with ValueNotifier for attributes _brightness and _contrast.
- Updated lib/features/personal_training_page/widgets/edit_history_dialog/widgets/distance_unit_row.dart:
  - Replaced Signal with ValueNotifier for attributes selectedUnit and selectedSpeedUnit.
- Updated lib/features/personal_training_page/widgets/edit_history_dialog/widgets/speed_unit_row.dart:
  - Replaced Signal with ValueNotifier for attributes selectedSpeedUnit and selectedDistUnit.
- Updated lib/features/users_page/widgets/dismissible_user_tile.dart:
  - Replaced Signal with ValueNotifier for attribute isChecked.
- Updated lib/features/users_page/widgets/user_dialog/user_controller.dart:
  - Replaced Signal with ValueNotifier for attribute image.
- Updated lib/features/widgets/edit_training_dialog/edit_training_dialog.dart:
  - Replaced Signal with ValueNotifier for attributes splitFocusNode, lapFocusNode, selectedDistUnit, and selectedSpeedUnit.
- Updated lib/features/widgets/edit_training_dialog/widgets/distance_unit_row.dart:
  - Replaced Signal with ValueNotifier for attributes selectedUnit and selectedSpeedUnit.
- Updated lib/features/widgets/edit_training_dialog/widgets/speed_unit_row.dart:
  - Replaced Signal with ValueNotifier for attributes selectedSpeedUnit and selectedDistUnit.
- Updated lib/features/stopwatch_page/stopwatch_page_controller.dart:
  - Replaced Signal with ValueNotifier for attributes _stopwatchLength and _historyMessage.
- Updated lib/features/widgets/precise_stopwatch/precise_stopwatch.dart:
  - Replaced Signal with ValueNotifier for attribute maxLaps.
- Updated lib/features/widgets/precise_stopwatch/widgets/counter_row.dart:
  - Replaced Signal with ValueNotifier for attribute counter.
- Updated lib/features/widgets/precise_stopwatch/widgets/lap_split_counters.dart:
  - Replaced Signal with ValueNotifier for attribute maxLaps.
- Updated lib/features/widgets/precise_stopwatch/widgets/stopwatch_display.dart:
  - Replaced Signal with ValueNotifier for attribute durationTraining.
- Removed Signal package from pubspec.yaml.
- lib/features/users_page/widgets/user_dialog/user_dialog.dart
- lib/features/settings/settings_page.dart:
- lib/features/stopwatch_page/stopwatch_page.dart:
- lib/features/widgets/common/custom_icon_button.dart
- lib/features/widgets/precise_stopwatch/precise_stopwatch_controller.dart:
- lib/features/widgets/precise_stopwatch/widgets/stopwatch_button_bar.dart:
  - Adjusted for the replacement of Signal with ValueNotifier.


## 2024_06_04 - version: 0.9.4+23

feat: Update app icons and improve tutorial content

This commit introduces the following changes:
- Updated application icons for various resolutions (hdpi, mdpi, xhdpi, xxhdpi, xxxhdpi).
- Added a new stopwatch icon in PNG and SVG formats.
- Enhanced tutorial content with detailed steps and messages.
- Updated translation files to include new tutorial messages in English, Spanish, and Portuguese.
- Added a new overlay for settings and users pages to provide a more comprehensive tutorial experience.
- Implemented a new class, `SettingsOverlay`, to manage tutorial steps for the settings page.
- Fixed a bug in the tutorial step sequence on the stopwatch page.
- Integrated `flutter_launcher_icons` package to manage app icons.
- Updated pubspec.yaml to include the new icon path and launcher icon configurations.

Changes in detail:

### Assets
- Added new icon files:
  - `assets/icons/stopwatch.png`
  - `assets/svgs/stopwatch.svg`
- Updated application icons in:
  - `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
  - `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
  - `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
  - `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
  - `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`
- Added images for tutorial:
  - `assets/images/dismissingLeft.png`
  - `assets/images/dismissingRight.png`

### Codebase
- `app_settings.dart`:
  - Updated to handle tutorial state and added methods to disable tutorial.
- `settings_overlay.dart`:
  - Created to manage tutorial steps for settings page.
- `settings_page.dart`:
  - Integrated `OnboardingOverlay` for the settings page tutorial.
- `stopwatch_overlay.dart`:
  - Enhanced with new tutorial steps and localized messages.
- `users_overlay.dart`:
  - Added detailed tutorial steps and messages.

### Translations
- Updated translation files:
  - `en-US.json`
  - `es.json`
  - `pt-BR.json`

### Pubspec
- Updated dependencies to include `flutter_launcher_icons` and configuration for the new app icon.

This update enhances the user experience by providing detailed guidance through tutorials and updating visual elements to align with the app's branding.


## 2024_06_03 - version: 0.9.3+22

refactor: Rename Athlete to User across the application

This commit includes comprehensive renaming of directories, files, variables, constants, classes, and functions to replace "Athlete" with "User". The term "User" aligns better with the application's purpose and scope.

Changes include:
- **Directory and file names**:
  - Renamed directories and files from `athlete*` to `user*`.

- **Variables and constants**:
  - Updated variable and constant names from `athlete*` to `user*`.

- **Classes and functions**:
  - Renamed classes and functions from `Athlete*` to `User*`.

These changes enhance clarity and consistency throughout the codebase, ensuring the terminology aligns with the app's intended functionality.


## 2024_06_03 - version: 0.9.2+21

feat: Add tutorial steps and enhance app settings

This commit introduces new tutorial steps using the onboarding_overlay package, adds a new image asset, and enhances app settings management. A bug fix in the `settingsTable` creation script has been made, and the database will now be removed if an error occurs during its creation.

### Images
- **assets/images/user_settings.png**:
  - Added new image asset for tutorial purposes.

### App Settings
- **lib/common/singletons/app_settings.dart**:
  - Added `disableTutorial` method to turn off the tutorial and update settings.
  - Removed `copy` method to avoid redundant data copying.
  - Enhanced `update` method for better settings management.

### Users Overlay
- **lib/features/users_page/users_overlay.dart**:
  - Added new onboarding steps for the Users page tutorial.
  - Included an option to interrupt the tutorial with explanatory text and buttons.

### Stopwatch Overlay
- **lib/features/stopwatch_page/stopwatch_overlay.dart**:
  - Added new onboarding steps for the Stopwatch page tutorial.
  - Included an option to interrupt the tutorial with explanatory text and buttons.
  - Improved the full-screen message layout for better user experience.

### Stopwatch Page
- **lib/features/stopwatch_page/stopwatch_page.dart**:
  - Enabled tutorial overlay display based on app settings.
  - Enhanced post-frame callback to manage tutorial states.

### Main Initialization
- **lib/main.dart**:
  - Adjusted initialization sequence to ensure settings are loaded before database initialization.

### Settings Model
- **lib/models/settings_model.dart**:
  - Added `showTutorial` attribute to manage tutorial display.
  - Enhanced `copy` method to include the new attribute.
  - Updated `toMap` and `fromMap` methods to handle `showTutorial`.

### Database Management
- **lib/store/constants/migration_sql_scripts.dart**:
  - Added migration script for version 1005 to include `showTutorial` column.
- **lib/store/constants/table_attributes.dart**:
  - Added `settingsShowTutorial` attribute.
- **lib/store/constants/table_sql_scripts.dart**:
  - Fixed bug in `createSettingsSQL` script and added `settingsShowTutorial` column.
- **lib/store/database/database_provider.dart**:
  - Updated initialization to handle app settings and migrations correctly.

### Version Update
- **pubspec.yaml**:
  - Updated version to `0.9.2+21`.

This commit ensures better management of app settings, introduces a comprehensive onboarding tutorial, and fixes potential issues in database initialization and migration processes.


## 2024_05_31 - version: 0.9.1+20

feat: Enhance stopwatch messaging and add onboarding tutorial

This commit introduces improvements to stopwatch messaging and adds support for the onboarding tutorial using the onboarding_overlay package. It also includes translations updates and several UI and backend adjustments. A bug fix in the `settingsTable` creation script has been made, and the database will now be removed if an error occurs during its creation.

### Translations
- **assets/translations/en-US.json**:
  - Updated `PSCStartedMessage`, `PSCSplitMessage`, `PSCLapMessage`, and `PSCFinishMessage` to remove redundant placeholders.

- **assets/translations/es.json**:
  - Updated `PSCStartedMessage`, `PSCSplitMessage`, `PSCLapMessage`, and `PSCFinishMessage` to remove redundant placeholders.

- **assets/translations/pt-BR.json**:
  - Updated `PSCStartedMessage`, `PSCSplitMessage`, `PSCLapMessage`, and `PSCFinishMessage` to remove redundant placeholders.

### Stopwatch Page
- **lib/features/stopwatch_page/stopwatch_page.dart**:
  - Added import for `MessagesModel`.
  - Changed `_messageList` to use `MessagesModel` instead of `String`.
  - Updated logic to handle `MessagesModel` instances.
  - Modified `_removeUserFromLogs` to use `message.title` for comparison.

- **lib/features/stopwatch_page/stopwatch_page_controller.dart**:
  - Changed `_historyMessage` to use `MessagesModel` instead of `String`.
  - Updated `sendHistoryMessage` to accept `MessagesModel`.

- **lib/features/stopwatch_page/widgets/message_row.dart**:
  - Changed `message` type to `MessagesModel`.
  - Updated `_buildMessageRow` and `_messageRow` to handle `MessagesModel` attributes.
  - Improved UI styling for message rows using `Container`.

### Trainings Page
- **lib/features/trainings_page/trainings_page.dart**:
  - Added elevation to `AppBar`.
  - Enhanced dropdown styling with `Container`.

### Precise Stopwatch Controller
- **lib/features/widgets/precise_stopwatch/precise_stopwatch_controller.dart**:
  - Changed messages to use `MessagesModel`.
  - Updated `_sendStartedMessage`, `_sendSplitMessage`, `_sendLapMessage`, and `_sendFinishMessage` to create `MessagesModel` instances.

### Settings Manager
- **lib/manager/settings_manager.dart**:
  - Added try-catch block to handle errors when querying settings.

### Database Manager
- **lib/store/database/database_manager.dart**:
  - Added logging and error handling for database creation.

### Messages Model
- **lib/models/messages_model.dart**:
  - Created new `MessagesModel` class to encapsulate message details.

### SQL Scripts
- **lib/store/constants/table_sql_scripts.dart**:
  - Added missing comma in `createSettingsSQL`.


## 2024_05_31 - version: 0.9.0+19

feat: Add onboarding tutorial using onboarding_overlay package

This commit integrates the onboarding_overlay package to provide an introductory tutorial for the app on two pages. It includes necessary adjustments to routes, FocusNodes, and user interfaces to support the tutorial.

- **lib/common/singletons/app_settings.dart**:
  - Added constant `maxFocusNode` to limit the number of FocusNodes for the tutorial.
  - Added `List<FocusNode> focusNodes` to store FocusNodes for the tutorial.
  - Added `tutorialOn` attribute to indicate if the tutorial is active.
  - Added `tutorialId` attribute to track the tutorial test user's ID.
  - Added disposal of elements in `focusNodes` in the `dispose` method.

- **lib/my_material_app.dart**:
  - Adjusted routes for `StopWatchPage` and `UsersPage` to use tutorial overlays `StopwatchOverlay` and `UsersOverlay`, respectively.

- **lib/screens/users_page/users_overlay.dart**:
  - Added `UsersOverlay` class to provide the tutorial for the `UsersPage`.

- **lib/screens/users_page/users_page.dart**:
  - Added tutorial entries in `initState`, `_addNewUser`.
  - Added a `PopupMenuButton` for tutorial entry.
  - Added `app.focusNode` for tutorial elements.

- **lib/screens/users_page/users_page_controller.dart**:
  - Added an entry to store the user ID used in the tutorial.

- **lib/screens/users_page/widgets/user_dialog/user_dialog.dart**:
  - Corrected attribute name from `sueUser` to `addUser`.

- **lib/screens/users_page/widgets/dismissible_user_tile.dart**:
  - Added a dialog for attempting to deselect an user when they have an active stopwatch on the main page.

- **lib/screens/widgets/common/generic_dialog.dart**:
- **lib/screens/widgets/edit_training_dialog/edit_training_dialog.dart**:
- **lib/screens/personal_training_page/widgets/edit_history_dialog/edit_history_dialog.dart**:
- **lib/screens/trainings_page/widgets/edit_training_dialog.dart**:
  - Replaced `ElevatedButton` with `FilledButton`.

- **lib/screens/stopwatch_page/stopwatch_overlay.dart**:
  - Added `StopwatchOverlay` class to provide the tutorial for the `StopWatchPage`.

- **lib/screens/stopwatch_page/stopwatch_page.dart**:
  - Added tutorial entries in `initState`, `_addNewUser`.
  - Added a `PopupMenuButton` for tutorial entry.
  - Added `app.focusNode` for tutorial elements.
  - Added a call to dispose `AppSettings.instance` in the `dispose` method of the class.

- **lib/screens/stopwatch_page/widgets/stopwatch_dismissible.dart**:
- **lib/screens/stopwatch_page/widgets/stopwatch_drawer.dart**:
- **lib/screens/widgets/common/custon_icon_button.dart**:
- **lib/screens/widgets/precise_stopwatch/widgets/stopwatch_button_bar.dart**:
  - Added `app.focusNode` for tutorial elements.

- **lib/screens/widgets/precise_stopwatch/precise_stopwatch.dart**:
  - `PreciseStopwatch` now passes `user.id` to the `StopwatchButtonBar` class.


## 2024/05/17 - version 0.8.2+17:

feat: Update translations, theme settings, and database schema for improved functionality and Flutter 3.22 compliance

This commit includes extensive updates to the translations, theme settings, and database schema. It aligns with Flutter 3.22 guidelines, adds new features such as contrast control, and makes several UI and backend adjustments.

- **assets/translations/??.json**:
  - Various updates to translations.

- **lib/common/constants.dart**:
  - Transferred `distanceUnits`, `speedUnits`, and `speedAllowedValues` to this constants file.

- **lib/common/singletons/app_settings.dart**:
  - Renamed variables `themeMode` and related ones to `brightness`, in accordance with Flutter 3.22 guidelines.
  - Added support for contrast control in the app.

- **lib/common/theme/color_schemes.g.dart**:
- **lib/common/theme/theme.dart**:
- **lib/common/theme/util.dart**:
  - Replaced `color_schemes.g.dart` with `theme.dart` and `utils.dart`, following new Flutter 3.22 guidelines.

- **lib/models/settings_model.dart**:
  - Added `Contrast` enum with elements: `{standard, medium, high}`.
  - Added attributes `lengthUnit` and `contrast`.
  - Renamed attribute `theme` to `brightness`.

- **lib/my_material_app.dart**:
  - Adjusted `MyMaterialApp` to use the new files generated by the Material Theme Builder (https://material-foundation.github.io/material-theme-builder/).
  - Updated to control theme brightness.

- **lib/screens/about_page/about_page.dart**:
  - The about page now includes a link to the project page.

- **lib/screens/settings/settings_page.dart**:
  - Replaced `_themeModeIcon` method with `_brightnessIcon`, now returning an `Icon` widget.
  - Added control for theme contrast.
  - Added editing of default lap and split lengths.

- **lib/screens/settings/widgets/length_line_edit.dart**:
  - Created `LengthLineEdit` class to manage lap and split length input lines.

- **lib/screens/stopwatch_page/widgets/stopwatch_drawer.dart**:
  - Changed the about page icon to `Icons.info_outline`.

- **lib/screens/trainings_page/widgets/dismissible_training.dart**:
  - Replaced the card with a `Container` and implemented selection control via the container's background color.

- **lib/screens/widgets/common/user_card.dart**:
  - Replaced the user card with a `Container`, similar to above.

- **lib/screens/trainings_page/widgets/dismissible_training.dart**:
  - Replaced card with a `Container` and implemented color control for selection. This was necessary as the dark theme currently lacks shadow on `Card` widgets. It is unclear if this is a bug or new directive in the current Material Theme.

- **lib/screens/widgets/edit_training_dialog/widgets/distance_unit_row.dart**:
- **lib/screens/widgets/edit_training_dialog/widgets/speed_unit_row.dart**:
  - Adjusted dropdown background color for better visibility in dark theme, for the same reason as above.

- **lib/screens/widgets/precise_stopwatch/precise_stopwatch.dart**:
  - Further color adjustments.

- **lib/store/constants/migration_sql_scripts.dart**:
  - Added migrations for database schema versions 1.0.3 and 1.0.4, including new columns `settingsLengthUnit` and `settingsContrast` in `settingsTable`.

- **lib/store/constants/table_attributes.dart**:
- **lib/store/constants/table_sql_scripts.dart**:
  - Added new columns `settingsLengthUnit` and `settingsContrast` to `settingsTable`.


## 2024/04/23 - version: 0.7.6+15

Enhancing Localization, Functionality, and Code Organization

- **Localization Updates**:
  - Added new entries to the localization files (`en-US.json`, `es.json`, `pt-BR.json`) for handling blocked actions and specifying the number of laps, which enhances the application's user interaction by providing more specific feedback in three different languages.

- **Functional Enhancements**:
  - Modified the `StopwatchBloc` to handle a maximum number of laps (`maxLaps`). This introduces functionality where the stopwatch can automatically stop counting upon reaching a specified number of laps.
  - Updated the `TrainingModel` to change `maxlaps` from a `double?` to an `int?`, aligning the data type more closely with its usage which typically involves whole numbers.

- **Code Refactoring**:
  - Moved `user_dialog` related files under `users_page/widgets`, improving project structure and modularity.
  - The `users_page` now incorporates logic to prevent the deletion of selected users, enhancing application stability and user experience.

- **User Interface Improvements**:
  - Integrated a new widget, `SimpleSpinBoxField`, which provides a user-friendly interface for adjusting numerical values. This widget is utilized in the `edit_training_dialog` to handle input for the maximum number of laps.

- **Database and Version Management**:
  - Adjusted SQL scripts to accommodate the change in data type of `maxlaps` in the training table.
  - Implemented more robust database migration handling within `database_migration` by dynamically adjusting to the latest schema version, improving maintenance and scalability.

- **Version Update**:
  - Updated the application's version in `pubspec.yaml` to reflect the new features and fixes.

This commit provides significant improvements across multiple areas of the Stopwatch application, from user-facing features to backend enhancements, ensuring a more robust and user-friendly experience.


## 2024/04/21 - version: 0.7.6+14

This commit enhances the multilingual support and updates the application's information management.

- **Enhanced Localization Support**:
  - Expanded translations for English (`en-US.json`), Spanish (`es.json`), and Brazilian Portuguese (`pt-BR.json`) to include new fields such as "Version", "Developer", and "Privacy Policy". This update aims to provide users with a richer, localized interface experience.

- **Documentation Updates**:
  - Updated the `pending.txt` document to include a new item about adding a column to the training table to store the start and end times of training sessions, reflecting an ongoing effort to enhance data management and application functionality.

- **Codebase Enhancements**:
  - Introduced the `AppInfo` class in `app_info.dart`, centralizing application-related information like version, developer contact, and privacy policy URLs. This class provides methods to launch URLs and compose emails, facilitating user interaction with app developers and legal information.
  - Updated the `AppFontStyle` in `app_font_style.dart` to include additional predefined text styles, improving consistency and ease of use across the application.
  - Adjusted `TrainingModel` in `training_model.dart` to include an optional `maxlaps` property, accommodating future features that may require tracking the maximum laps in a training session.

- **User Interface Updates**:
  - Added the `AboutPage` to provide users with application information, including version details, developer contact, and privacy policy access.
  - Enhanced the settings page (`settings_page.dart`) with refined localization keys, aligning with the new translations and ensuring that the interface remains consistent and user-friendly.

- **Architectural Improvements**:
  - Updated database schema management scripts (`migration_sql_scripts.dart` and related SQL scripts) to handle new database migrations smoothly, ensuring that the application's underlying data structure supports the latest features without disrupting existing functionality.

- **Integration of URL Launcher**:
  - Integrated the `url_launcher` package to handle external links effectively, enabling the application to interact with web browsers and external mail applications seamlessly.

This set of enhancements not only broadens the application's international appeal but also improves its informational and configurational aspects, making it more accessible and user-friendly.


## 2024/04/19 - version: 0.7.6+13

This commit introduces internationalization and settings management improvements to the Stopwatch application, enhancing user experience and language support.

- **Localization Files Addition**:
  - Added localization files for English (`en-US.json`), Spanish (`es.json`), and Brazilian Portuguese (`pt-BR.json`), located in the `assets/translations` directory. These files include translations for various UI elements such as buttons and dialog messages, enhancing the app's accessibility for a broader audience.

- **Enhancements in Settings Management**:
  - Updated the `StopwatchBloc` to refer to the new `mSecondRefresh` property in `AppSettings` for timer periodicity, aligning variable names for better code readability and consistency.
  - Expanded the `AppSettings` class to include multiple settings like theme mode, refresh rates, and language preferences, supporting a more customized user experience. The class now inherits from `SettingsModel`, allowing for easier settings management and updates.
  - Introduced a new `SettingsManager` to handle settings retrieval and updates, ensuring settings are consistently managed and stored.
  - Implemented new classes for settings persistence including `SettingsStore` and `SettingsRepository`, facilitating the storage and retrieval of user settings from a local database.

- **Infrastructure and Code Organization**:
  - Refined the database management structure by segregating database-related files into a `database` directory, which now includes files like `DatabaseManager`, `DatabaseBackup`, and `DatabaseMigration`.
  - Refactored various stores (`AccountStore`, `BalanceStore`, `CategoryStore`, etc.) by moving them into a new `stores` directory to streamline the project structure.

- **User Interface and Interaction**:
  - Modified the `Info.plist` file in the iOS project to include new localizations, expanding the app's reach to Norwegian and English speakers.
  - Updated the `AppSettings` singleton initialization to sync with the new settings structure, ensuring that the app correctly loads and applies user preferences at startup.
  - Enhanced the main application entry (`main.dart`) to initialize and apply localization settings using the `EasyLocalization` package, supporting dynamic language switching based on user preferences.

Overall, these changes make the Stopwatch app more versatile and user-friendly, catering to a global audience with multilingual support and customizable settings.


## 2024/03/18 - version: 0.7.3+10:

This release introduces a series of functionality improvements and interface updates to enhance user interaction and system efficiency within the Trainers Stopwatch app.

- **Stopwatch Bloc Enhancements:**
  - Added attributes `_endTime`, `_lastLapTime`, `_lastSplitTime`, `_lapDuration`, and `_splitDuration` to StopwatchBloc for better control over recorded times. This change allowed for the removal of some controls from `PreciseStopwatchController` directly into StopwatchBloc.
  - Events were reformulated to accommodate new responsibilities related to time management.
  - Created methods `_updatePausedTimes`, `_restartTimesAndCounters`, `_updateLap`, and `_updateSplit` to better separate responsibilities and facilitate code reusability.

- **Utility Functions and Bug Fixes:**
  - Introduced `StopwatchFunctions` class to package common app functions, initially including `speedCalc`.
  - Fixed a bug in `TrainingManager` that incorrectly handled zero-index checks, ensuring more robust data handling.

- **UI Components and Dialog Enhancements:**
  - Removed the Card from `DismissibleUserTile` and incorporated it into a new `UserCard` class for better code reusability and streamlined design.
  - In `PersonalTrainingPage` and related widgets, speed calculation now utilizes `StopwatchFunctions.speedCalc` for enhanced performance metrics.
  - `TrainingsPage` now includes new commands such as `_editTraining`, `_removeTraining`, `_selectAllTraining`, and `_deselectAllTraining`, with added widgets to facilitate these actions.
  - Separated `DismissibleTraining` class into its own file to clean up the codebase and improve maintainability.
  - Added `TrainingItem` class in `TrainingsPageController` to simplify the management of training selections and operations.
  - Introduced `EditTrainingDialog` class for editing training details directly from the UI.

- **Precise Stopwatch Controller Adjustments:**
  - Shifted the control of Laps and Splits from `PreciseStopwatchController` to StopwatchBloc, centralizing time control.
  - Added `_getSplit` method to return corrected split times, enhancing the accuracy of performance tracking.

This update aims to streamline the app's operations and enhance the user experience with clearer controls and improved data management.


## 2024/03/16 - version: 0.7.2+9:

* doc/pending.txt:
  - Removed outdated tasks and streamlined the document with new priorities including user message editing and disposal checks.
  - Added initialization of a default user on app start if none exists.

* lib/common/singletons/app_settings.dart:
  - Added a dispose method to clean up the theme mode listener.

* lib/common/theme/app_font_style.dart:
  - Updated font styles to include semi-bold instead of bold and added new size variants for better text clarity.

* lib/manager/user_manager.dart:
  - Converted UserManager into a singleton and added initialization checks to prevent multiple instances.
  - Added methods to ensure that all users are loaded when the manager is first accessed.

* lib/manager/training_manager.dart:
  - Added a flag to prevent reinitialization of the training manager.
  - Enabled creation of a training manager by user ID, which initializes training sessions specific to an user.

* lib/my_material_app.dart:
  - Expanded routing to include new pages for settings, training and about, enhancing navigation options within the app.

* lib/screens/about_page/about_page.dart:
  - Added a new About page with basic placeholder content.

* lib/screens/user_dialog/user_dialog.dart:
  - Adjusted the user dialog to reflect changes in font style from bold to semi-bold.

* lib/screens/users_page/users_page.dart:
  - Added initial loading logic to pre-select users who are already engaged in activities to prevent their deselection.

* lib/screens/personal_training_page/personal_training_page.dart:
  - Refactored to use a dedicated dismissible widget class for better modularity and maintenance.

* lib/screens/personal_training_page/widgets/dismissible_personal_training.dart:
  - Created a new stateful widget for dismissible elements in the personal training page to handle specific training session interactions like editing and deleting.

* lib/screens/settings/settings_page.dart:
  - Introduced a settings page to the application for better user configuration management.

* lib/screens/stopwatch_page/stopwatch_page.dart:
  - Refined message handling in the stopwatch page to prevent duplicate messages and improved UI updates through state management.

* lib/screens/trainings_page/trainings_page.dart:
  - Added a training page that handles the display and management of user-specific training sessions.

* lib/screens/widgets/common/generic_dialog.dart:
  - Renamed method from callDialog to open for clarity and consistency in usage.

* lib/screens/widgets/common/set_distance_dialog.dart:
  - Renamed SetDistanceDialog to EditTrainingDialog and expanded its functionality to include editing comments on training sessions.

This commit introduces several structural improvements, new features, and user interface enhancements to enhance the functionality and usability of the app.


## 2024/03/15 - version: 0.7.1+8:

This release focuses on improving functionality and user interface enhancements across various components of the Trainers Stopwatch app.

- **Stopwatch Bloc Enhancements**:
  - Renamed `_counter` to `_lapCounter` to better reflect its purpose.
  - Introduced `_splitCounter` for counting splits.
  - Simplified the increment process for splits to fix a counting bug.

- **Model Updates**:
  - In `HistoryModel`, added an `int split` attribute to directly record splits instead of calculating them.

- **Users Page Enhancements**:
  - Introduced a list of pre-selected user IDs, `_preSelectedUserIds.addAll`, which locks the selected users from being deselected on the `UsersPage`. This ensures users with active stopwatches are not accidentally deselected.
  - In `DismissibleUserTile`, user lock control is managed, and the checkbox for user selection has been replaced with a card elevation of 5, enhancing the aesthetic appeal.

- **Personal Training Page Refactoring**:
  - Refactored to remove `Dismissible` into a dedicated class `DismissiblePersonalTraining`.

- **Stopwatch Page Improvements**:
  - Removed `SnackBar` from `StopwatchPage`. Currently testing a `ListView.builder` for displaying messages in a reserved area at the bottom of the `StopwatchPage`.
  - Added an effect function (from `Signal`) to enhance reactivity for adding new messages to `_messageList` as they are generated.
  - Implemented `setState` in `_addStopwatches` and `_removeStopwatch` due to changes in page update dynamics.
  - Extracted `listViewBuilder` construction into a dedicated function for improved code readability.
  - Simplified the presentation of stopwatch commands on `StopwatchPage`, removing several rows and columns for a cleaner layout.

- **Additional Component Updates**:
  - Created `MessageRow` to construct log entries for the stopwatch.
  - Introduced `StopwatchDismissible` to isolate `Dismissible` behavior specifically for the `StopwatchPage`.
  - Enhanced `NumericField` to allow only valid numbers.
  - Adjusted focus management in `SetDistanceDialog` to better navigate its elements.
  - Merged Split and Lap buttons in `PreciseStopwatch` since the end of a Lap also signifies the end of a Split. These buttons now share the same position, with the Lap button displayed at the end of a Lap and the Split button visible during other operations.

- **Precise Stopwatch Controller Adjustments**:
  - Added `isPaused` to manage stopwatch pauses.
  - Streamlined the injection of new Splits and Laps to a more simplistic model.
  - Replaced the generic `_createMessage` method with specific methods: `_sendSplitMessage`, `_sendLapMessage`, `_sendFinishMessage`, and `_sendStartedMessage`.
  - Simplified `speedCalc` method to require fewer parameters.

- **Database Schema Updates**:
  - Added `historySplit` constant to name the split column in the `historyTable`.
  - Modified SQL to include the `split` column in the `historyTable`.

This update aims to streamline the app's functionality while enhancing the user experience with more intuitive controls and clearer information display.


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
  - Renamed `_selectedUsers` to `_stopwatchList` and introduced `_stopwatchControllers`.
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
  - Standardized error messages within `UserManager`.
  - Launched `HistoryManager` to oversee training history models.
  - Introduced `TrainingManager` to manage user training models.

- **Model Enhancements**:
  - `TrainingModel` now includes attributes to store the lengths of splits and laps, adding detailed tracking capabilities.

- **MyMaterialApp**:
  - Implemented theme selection support within the app for enhanced user personalization.

- **User Dialog Adjustments**:
  - Modified the user dialog for both adding and updating user details, improving usability.

- **Users Page Enhancements**:
  - Added editing and removal capabilities for users on the `UsersPage`, enhancing management efficiency.

- **Users Page Controller**:
  - Integrated methods to update and delete users, supporting robust user management.

- **Dismissible User Tile**:
  - Introduced `editFunction` and `deleteFunction` callbacks to facilitate user management directly from the UI.

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

- **Show User Image Updates**:
  - Modified to accept an optional window size parameter, enhancing flexibility in image presentation.

- **Precise Stopwatch Updates**:
  - Removed `StopwatchBloc` from `PreciseStopwatch`. The bloc is now instantiated in the `PreciseStopwatchController`, centralizing all stopwatch control logic in the controller.
  - Adjusted layout to accommodate a text line displaying information on splits and laps when recorded.

- **Precise Stopwatch Controller**:
  - Created `PreciseStopwatchController` to handle business logic for `PreciseStopwatch`, encompassing all control logic previously in `StopwatchBloc` and adding split and lap record management.

These updates significantly enhance the app's configurability, user interaction, and overall efficiency, providing a more tailored and professional experience for trainers managing multiple users.


## 2024-04-10 - version: 0.4.2+5

Significant enhancements and refinements have been implemented in the Trainers Stopwatch app:

- **StopwatchBloc Enhancements**:
  - Transitioned from `ValueNotifier` to `Signal` for a more streamlined and elegant approach.
  - Removed `splitDuration` and `counterDuration` as they were deemed unnecessary.
  - The `_stopEvent` method has been optimized and simplified, ensuring accurate stop timing and lap counter adjustments.
  - Updated the display time in the `_pauseEvent` method for a more precise presentation of the pause moment.

- **Font Style Consolidation**:
  - All font styles are now centralized within the `AppFontStyle` class, promoting consistency and ease of maintenance.

- **User Dialog and Tile Updates**:
  - User images are now handled through `Signal`, enhancing the reactivity and update efficiency.
  - User images are displayed using the `ShowUserImage` class, standardizing image presentation.
  - Modified `DismissibleUserTile` to use a `Signal` for user selection (`isChecked` signal).

- **Stopwatch Page and Controller Logic**:
  - Relocated PreciseTimer allocation logic for users to `StopwatchPageController`, streamlining the control mechanism.

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

- **Common Constants**: Introduced a `constants.dart` file for app-wide constants, including `photoImageSize` for image sizing and `defaultPhotoImage` providing a default user image string.

- **Custom Icons**: Added a new set of custom icons specific to the app, enhancing the visual appeal and user experience.

- **App Settings Singleton**: Implemented the `AppSettings` singleton class to store system-wide variables like `imagePath`, organizing internal storage for user images.

- **Database and Settings Initialization**: The main entry point now includes database and app settings initialization, laying a solid foundation for the app's data handling.

- **User Manager**: The `UserManager` class is introduced for comprehensive management of user-related operations, handling the business logic for user actions such as registration, editing, and deletion.

- **Data Models**: Data models for users, training sessions, and history are fully integrated with the store and repository layers, though currently, only user models are worked on within the manager layer.

- **Page Routing**: Routing for `StopWatchPage` and `UsersPage` is set up, facilitating navigation within the app.

- **Repository Layer**: The repository layer is now fully implemented for users, history, and training, performing basic database operations and bridging app objects to database maps.

- **User Dialog UI**: A new `UserDialog` class introduces a dialog for adding new users, complemented by `UserController` for handling form UI elements and `Validator` for input validation. A custom `TextField` widget is designed specifically for this dialog.

- **Users Page for Management**: The `UsersPage` allows for user management within the app, with current functionality for adding new users. Future updates will include editing and removal options.

- **Dismissible User Tile**: Customized Dismissible widget for user management in `UsersPage`.

- **Stopwatch Page Adjustments**: Adjusted to display stopwatches for selected users from `UsersPage`.

- **Database Store and Management**: Implemented insertion, update, deletion, and search methods across all app models. Additionally, constants for table names, attributes, and SQL creation scripts are defined, alongside static classes for database table creation and a `DatabaseManager` for overall database management.

- **Dependencies Update**: The `pubspec.yaml` file has been updated with packages for SQLite database (`sqflite`), file path extraction (`path_provider` and `path`), testing mocks (`mockito`), Observer pattern implementation (`signals`), and device camera access (`image_picker`). Also, added the custom `StopwatchIcons` font.

This version marks a significant step towards realizing a robust, professional stopwatch application tailored for trainers managing multiple users, combining precise timing functionalities with comprehensive user management and history tracking capabilities.


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
