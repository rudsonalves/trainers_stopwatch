# Changelog

## 2026/08/13 - bkl002/task06

This change introduces immutable, infrastructure-independent domain entities for users, training sessions, history, settings, stopwatch state, and reporting events. The new models enforce domain invariants through result-based factories and provide value equality for predictable comparisons.

The accompanying tests cover defaults, validation rules, optional persistence identifiers, zero-duration scenarios, and equality behavior. The domain-purity backlog was updated to mark the corresponding modeling and event tasks as complete.

1. **Android Gradle configuration**

   * Added the Flutter migrator-generated `android.builtInKotlin` and `android.newDsl` compatibility flags.
   * Explicitly disabled both settings to preserve the current Android build behavior.

2. **User domain model**

   * Added an immutable `User` entity containing domain-relevant identity and contact information.
   * Kept the identifier optional to support users that have not yet been persisted.
   * Added value-based equality and hash-code generation without introducing serialization or UI dependencies.

3. **Training domain model**

   * Added an immutable `Training` entity with persisted user association, date, comments, typed split and lap distances, optional lap limit, and typed speed unit.
   * Added metric defaults of 200 meters per split and 1,000 meters per lap.
   * Added validation for persisted user IDs, positive lap limits and distances, matching distance units, and compatible distance and speed units.
   * Kept training identifiers optional and excluded presentation-specific data such as colors.

4. **History domain model**

   * Added an immutable `HistoryEntry` entity associating a persisted training with its duration and optional comments.
   * Allowed `Duration.zero` for the initial session record while rejecting negative durations and invalid training identifiers.
   * Added value equality for reliable comparisons.

5. **Settings domain model**

   * Added immutable settings for split and lap distances, brightness, contrast, language, refresh interval, and tutorial visibility.
   * Introduced typed brightness, contrast, and language preferences with English/United States as the default locale.
   * Added metric distance defaults, dark brightness, standard contrast, a 66-millisecond refresh interval, and enabled tutorial visibility.
   * Added validation for positive same-unit distances and positive refresh intervals.
   * Kept the model free of widget state, focus objects, paths, and other presentation-specific dependencies.

6. **Stopwatch snapshots**

   * Added a sealed snapshot hierarchy for split, lap, and finish states.
   * Represented elapsed and segment durations, lap counts, and split counts as immutable domain values without notifier dependencies.
   * Added shared validation for non-negative durations and counters and prevented segment durations from exceeding total elapsed time.
   * Allowed zero durations and counters so later domain calculations can classify initial states.
   * Added value equality for every snapshot type.

7. **Training report events**

   * Added a sealed, presentation-neutral `TrainingEvent` hierarchy for session starts, recorded splits, and recorded laps.
   * Kept start events free of calculated measurement data.
   * Added measured-event factories carrying typed speed, duration, index, optional history association, and comments.
   * Added validation for positive event indices and non-negative durations.
   * Excluded colors, icons, translated labels, and route information while providing value equality.

8. **Domain model and event tests**

   * Added tests for user persistence semantics and value equality.
   * Added training tests covering metric defaults, invalid user IDs, lap limits, zero distances, mismatched distance units, incompatible speed units, and equality.
   * Added history tests covering zero-duration initial entries, persisted training requirements, negative-duration rejection, and equality.
   * Added settings tests covering application defaults, distance and refresh invariants, and equality.
   * Added stopwatch snapshot tests covering captured timing data, zero durations, invalid durations and counters, elapsed-time constraints, and equality.
   * Added training event tests covering neutral start events, measured split and lap data, validation failures, and equality.

9. **Domain-purity backlog**

   * Marked the immutable user, training, history, and settings model requirements as complete.
   * Marked persistence-ID, metric-default, domain-purity, and model-invariant testing requirements as complete.
   * Marked stopwatch snapshot and neutral training-event requirements, including validation and comparison coverage, as complete.

### Conclusion

The domain layer now provides immutable, validated models for core training data and neutral temporal reporting. These types can be shared by future repositories, use cases, view models, and reports without coupling domain behavior to infrastructure or UI state.

Automated tests establish the expected defaults, invariants, zero-duration behavior, and value semantics across the new model hierarchy.

## 2026/08/13 - bkl002/task04

This change begins the pure-domain extraction by establishing dependency boundaries and introducing typed training units, distance and speed values, and a centralized speed calculation service.

The domain now validates persisted unit symbols, supported unit combinations, numeric invariants, and elapsed time through typed results. Backlog documentation and automated tests capture the architectural decisions and verify the new behavior.

1. **`lib/domain/common/`**

   * Added documentation defining the domain’s permitted dependencies and excluding Flutter, persistence, repositories, localization, navigation, and presentation concerns.
   * Established a minimal organization strategy that creates domain contexts only when concrete types are implemented.

2. **`lib/domain/common/training/units/`**

   * Added `DistanceUnit` for meters, kilometers, yards, and miles, with meters as the default and explicit conversion factors to meters.
   * Added `SpeedUnit` for meters per second, kilometers per hour, yards per second, and miles per hour, with meters per second as the default.
   * Added typed parsing and serialization for the existing persisted unit symbols.
   * Returned `invalidData` failures for unknown symbols instead of silently applying defaults.
   * Added the existing distance-to-speed compatibility matrix and an operation for validating unit combinations.

3. **`lib/domain/common/training/values/`**

   * Added immutable `Distance` and `Speed` value objects with value equality.
   * Added typed factories that reject negative and non-finite values while allowing zero.
   * Added distance normalization to meters and speed conversion from meters per second without presentation-layer rounding.
   * Preserved the application’s existing conversion factors for all supported units.

4. **`lib/domain/common/training/services/speed_calculator.dart`**

   * Added a typed speed calculation service that normalizes distance to meters and duration to seconds before converting to the requested output unit.
   * Added explicit validation for zero and negative durations, incompatible unit combinations, and non-finite calculation results.
   * Preserved microsecond precision and returned typed `Speed` results without rounding.
   * Allowed zero distance to produce zero speed while preventing division by zero.

5. **`lib/core/result/errors/app_error_code.dart`**

   * Added the `zeroElapsedTime` error code to distinguish zero-duration speed calculations from general invalid data.

6. **`test/domain/common/training/`**

   * Added unit parsing and serialization tests for every supported distance and speed symbol, including unknown-value failures.
   * Added coverage for the complete distance and speed compatibility matrix.
   * Added value-object tests for defaults, zero values, conversion factors, invalid numeric inputs, and equality.
   * Added speed calculator tests for metric defaults, all supported output units, microsecond precision, zero distance, invalid durations, and incompatible units.
   * Verified compatibility with the conversion behavior already used by the application.

7. **`doc/backlog/002-dominio-puro.md` and `002-dominio-puro-tasks.md`**

   * Added a detailed implementation checklist for the pure-domain backlog and marked the domain foundation, unit modeling, value objects, and speed calculation tasks as completed.
   * Resolved the open decisions concerning transient training colors, zero-duration handling, metric defaults, supported unit combinations, and neutral report events.
   * Documented the consequences for domain isolation, persistence compatibility, presentation formatting, and future report generation.
   * Linked the backlog document to its implementation task tracker.

8. **`Changelog.md`**

   * Added the completed architectural foundation changelog entry covering typed results, commands, dependency injection, bootstrap error handling, database initialization, logging, tests, and backlog closure.
   * Removed the obsolete unreleased placeholder from the end of the changelog.

### Conclusion

The project now has a pure-Dart foundation for training units, distance and speed values, and validated speed calculations. Invalid units, numeric values, and elapsed times are represented through explicit typed failures.

The accompanying tests and backlog documentation establish the implemented domain boundaries and preserve existing conversion and compatibility behavior for subsequent domain extraction work.

## 2026/08/13 - update/backlog-02

This change completes the architectural foundation backlog by introducing typed result and command abstractions, centralized dependency injection, and a structured application bootstrap flow.

Database initialization now reports explicit failures for opening, creation, settings, backup, migration, and restoration operations. The application handles bootstrap failures with a minimal error screen instead of terminating the process, while documentation and tests record and validate the delivered architecture.

1. **`lib/core/result/`**

   * Added the generic `Result<T>` abstraction with `Success<T>`, `Failure<T>`, typed value and error accessors, state checks, and `fold` handling.
   * Added `AsyncResult<T>` for asynchronous typed operations and `Unit` for successful operations without meaningful return values.
   * Introduced `AppError` with an error code, user-facing message, and optional diagnostic details.
   * Added the initial `AppErrorCode` catalog covering database availability and creation, migrations, backups, restoration, storage access, invalid data, and unexpected failures.
   * Added `Command0` and `Command1` abstractions with idle, running, success, and failure states.
   * Prevented concurrent execution of the same command, preserved expected `AppError` failures, and converted unexpected exceptions into typed errors containing diagnostic details.

2. **`lib/core/config/dependencies.dart` and dependency manifests**

   * Added `auto_injector` as a direct application dependency.
   * Created an idempotent composition root that registers the existing `DatabaseManager` and `AppSettings` singletons as temporary instances.
   * Registered `DatabaseProvider` and `Bootstrap` for constructor-based dependency resolution.
   * Updated `pubspec.yaml` and `pubspec.lock` with `auto_injector` version `2.2.0`.

3. **`lib/core/bootstrap/bootstrap.dart` and `lib/main.dart`**

   * Added a `Bootstrap` service that delegates database initialization and returns `AsyncResult<Unit>`.
   * Refactored application startup to configure dependencies and resolve the bootstrap service through the injector.
   * Added an early failure path that removes the native splash screen and displays a minimal `BootstrapErrorApp`.
   * Exposed the bootstrap error code in the fallback interface instead of allowing initialization failures to terminate the process.
   * Preserved the localized main application startup path after successful initialization.

4. **`lib/store/database/`**

   * Refactored `DatabaseProvider` to receive `DatabaseManager` and `AppSettings` through constructor injection.
   * Changed database initialization to return typed success or failure results.
   * Added distinct handling for settings reads, database backups, migrations, and backup restoration.
   * Prevented migrations from running when the required backup cannot be created.
   * Restored the backup after migration failure and differentiated successful restoration from restoration failure through separate error codes.
   * Converted unexpected initialization exceptions into typed errors while retaining diagnostic information.
   * Replaced `DatabaseCreationException` and process termination in `DatabaseManager` with typed `AppError` failures.
   * Distinguished failures opening the database from failures creating its schema.

5. **`lib/manager/settings_manager.dart`**

   * Stopped treating every settings query error as an absent settings record.
   * Retained automatic creation only for genuinely missing settings.
   * Converted failures while inserting initial settings into a typed `storageWriteFailed` error with diagnostic details.

6. **`lib/core/services/logging/console_log.dart`**

   * Added a development-only console logging service with contextual error, warning, and informational levels.
   * Included optional error and stack-trace reporting for diagnostics while suppressing console output outside debug builds.

7. **Analyzer configuration and relative imports**

   * Simplified `analysis_options.yaml` while retaining the standard Flutter lint configuration.
   * Configured the formatter to preserve trailing commas.
   * Enabled relative-import enforcement and disabled the initializing-formals preference.
   * Converted affected imports in application settings, training overlay, and training dialog modules to relative paths.
   * Applied formatting cleanup to existing copyright headers.

8. **`test/core/result/`**

   * Added tests for successful and failed results, including value and error exposure and both `fold` branches.
   * Added command tests covering state transitions, listener notifications, successful values, expected errors, unexpected exceptions, concurrent execution prevention, and input forwarding.

9. **`test/core/config/dependencies_test.dart`**

   * Added coverage confirming that dependency setup is idempotent.
   * Verified that the injector resolves the database provider and complete bootstrap graph without invoking platform APIs.

10. **`doc/backlog/closed/001-fundacao-arquitetural.md` and task tracking**

   * Moved the architectural foundation backlog into the closed backlog directory.
   * Recorded the final bootstrap, backup, migration, and restoration decisions and removed the resolved open questions.
   * Marked the backlog as completed on 2026-08-13 and documented the delivered implementation, validation results, remaining temporary adapters, and deferred work.
   * Added a completed task checklist covering result contracts, commands, shared infrastructure, bootstrap adaptation, validation, and documentation.
   * Updated the next-backlog link for the document’s new location.

11. **`doc/backlog/README.md`, `002-dominio-puro.md`, and `003-persistencia-e-repositories.md`**

   * Updated the backlog index to link to the closed architectural foundation document.
   * Marked backlog 001 and its downstream dependency status as completed.
   * Updated domain and persistence backlog references to reflect the completed prerequisite.

### Conclusion

The application now has a typed foundation for results, errors, commands, dependency resolution, and startup orchestration. Database initialization failures are represented explicitly and surfaced through a controlled fallback interface.

The architectural foundation backlog is documented as complete, with automated coverage for its core abstractions and composition graph and clear dependency updates for subsequent backlog work.

## 2026/08/13 - update/backlog-01

This change establishes the architectural baseline and implementation roadmap for incrementally migrating Trainer's Stopwatch to MVVM while retaining BLoC for the stopwatch timing core. It documents the current system, defines the target layering and responsibilities, and organizes the migration into ten dependent backlogs.

The update also modernizes the Flutter dependency set and related APIs, restores iOS CocoaPods configuration, refreshes generated Linux plugin registration, and applies compatibility and lint improvements across the application.

1. **Project documentation and changelog**

   * Added `Changelog.md` with an initial unreleased section.
   * Expanded `README.md` with links to the current architecture assessment, MVVM restructuring plan, and implementation backlog.
   * Added `doc/arquitetura_atual.md` describing application initialization, navigation, state management, stopwatch behavior, managers, repositories, stores, SQLite persistence, global configuration, integrations, and existing architectural coupling.
   * Added `doc/plano_reestruturacao_mvvm.md` defining the target `core`, `domain`, `data`, and `ui` layers, constructor-based dependency injection, typed results and errors, ViewModel responsibilities, persistence boundaries, and the continued use of BLoC for monotonic stopwatch timing.
   * Documented the incremental migration strategy, architectural risks, completion criteria, and recommended first delivery.

2. **`doc/backlog`**

   * Added a backlog index defining execution order, dependency relationships, migration rules, and the lifecycle for each implementation increment.
   * Added backlog 001 for architectural foundations, including `Result`, `AppError`, `Unit`, Commands, logging, `AutoInjector`, bootstrap error handling, and dependency rules.
   * Added backlog 002 for extracting Flutter-independent domain models, units, calculations, temporal snapshots, and lap/split rules.
   * Added backlog 003 for injectable DAOs and repositories that preserve the existing SQLite schema, migrations, backup, and restoration behavior.
   * Added backlog 004 for using settings as the first end-to-end MVVM migration.
   * Added backlog 005 for migrating users and image operations behind repositories and injectable file services.
   * Added backlog 006 for migrating training and history flows to ViewModels, domain models, repositories, and coordinated use cases.
   * Added backlog 007 for rebuilding the stopwatch BLoC around `dart:core Stopwatch`, immutable state, and deterministic temporal behavior.
   * Added backlog 008 for representing multiple athlete stopwatches as independently managed sessions instead of widgets stored in a global controller.
   * Added backlog 009 for separating report content, PDF rendering, temporary files, email, and sharing behind injectable services.
   * Added backlog 010 for consolidating the migrated UI, centralizing routes, removing obsolete legacy components, and validating supported platforms.

3. **Flutter dependencies and lockfile**

   * Upgraded `flutter_bloc`, `bloc_test`, `google_fonts`, `flutter_email_sender`, `share_plus`, `flutter_lints`, and `flutter_launcher_icons`.
   * Regenerated `pubspec.lock` with updated direct and transitive packages, including newer analyzer, testing, SQLite, image, localization, sharing, platform, and tooling dependencies.
   * Raised the resolved SDK requirements to Dart 3.12 and Flutter 3.44.
   * Added transitive platform packages required by the upgraded dependency graph, including JNI, Objective-C, native asset, and split platform implementations.

4. **Sharing integration**

   * Migrated PDF sharing from the deprecated static `Share.shareXFiles` API to `SharePlus.instance.share`.
   * Wrapped the generated PDF and subject in `ShareParams` for compatibility with the upgraded `share_plus` package.

5. **Flutter UI compatibility**

   * Replaced deprecated `Color.withOpacity` calls with `Color.withValues(alpha:)` across stopwatch, settings, users, trainings, history, onboarding overlays, dialogs, cards, counters, dismissible components, and shared buttons.
   * Preserved the existing alpha values and visual behavior while aligning the UI with the current Flutter color API.
   * Reordered affected imports and normalized source formatting where required by the updated tooling.

6. **Stopwatch BLoC and application metadata**

   * Added explicit `void` return types to internal stopwatch timing and counter update helpers.
   * Added an explicit `String` return type to the application page URL getter.
   * Reformatted the privacy policy constant and normalized license-header whitespace without changing runtime behavior.

7. **iOS platform configuration**

   * Added the Flutter CocoaPods `Podfile` with Runner build mappings, Flutter SDK discovery, plugin installation, Runner test inheritance, and post-install build settings.
   * Updated Debug and Release xcconfig files to optionally include their corresponding CocoaPods-generated Runner configurations before Flutter-generated settings.

8. **Linux plugin registration**

   * Registered the `jni` FFI plugin in the generated Linux CMake plugin list to match the updated resolved dependencies.

### Conclusion

The project now has a documented architectural baseline and an ordered, dependency-aware roadmap for migrating to MVVM while preserving the specialized stopwatch BLoC and existing data compatibility.

The Flutter toolchain and package ecosystem have also been modernized, with application APIs and native platform configuration updated to support the new dependency versions without introducing intended functional changes.
