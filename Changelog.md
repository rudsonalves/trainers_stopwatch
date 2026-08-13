# Changelog

## 2026/08/13 - bkl003/task04

This change establishes the new persistence-layer foundation and migrates settings storage toward injectable data services. It introduces centralized database lifecycle, schema, backup, and settings services while documenting the intended dependency boundaries for repositories and data access.

Database versioning is now managed exclusively through SQLite schema version `1006`. Incompatible databases are preserved through timestamped backups before replacement, and settings no longer carry database schema metadata.

1. **`lib/data`**

   * Added architectural documentation for the `Viewmodel/UseCase -> Repository -> Data Service -> Database` dependency direction.
   * Defined responsibilities and dependency restrictions for repositories and data services.
   * Documented constructor injection, cache ownership, persistence isolation, incremental module organization, and temporary legacy exceptions.

2. **`lib/data/services/database`**

   * Added `DatabaseService` to encapsulate connection opening, reuse, configuration, and closing.
   * Enabled SQLite foreign keys whenever a connection is opened.
   * Added concurrent opening coordination and `Result`-based handling for database lifecycle failures.
   * Added `DatabaseSchema` to create the current tables and indexes through a single batch operation.
   * Added `DatabaseBackupService` to preserve incompatible databases using timestamped, recoverable filenames.
   * Implemented detection of databases whose native SQLite version differs from `1006`, followed by backup and controlled replacement.
   * Added explicit `backupFailed`, `migrationFailed`, `databaseCreationFailed`, and `databaseUnavailable` error handling.

3. **`lib/data/services/settings`**

   * Added `SettingsService` with injectable database and mapper dependencies.
   * Implemented settings lookup, insertion, and update operations using domain models and `Result` values.
   * Added explicit `SettingsFound` and `SettingsMissing` lookup outcomes.
   * Added `SettingsMapper` to isolate record conversion, apply persisted-value defaults, validate distance values and units, and convert invalid records into `invalidData` errors.
   * Added storage-specific read and write error handling.
   * Removed database schema metadata from serialized settings records.

4. **`lib/core/config/dependencies.dart`**

   * Registered the database schema, backup service, database service, settings mapper, and settings service with `AutoInjector`.
   * Configured `DatabaseService` as the injector-managed singleton responsible for application database access.
   * Connected the service to the application documents directory and the `sqflite` database factory.
   * Retained the legacy `DatabaseManager` registration temporarily for consumers not yet migrated.

5. **Settings models and adapters**

   * Removed `dbSchemeVersion` from `SettingsModel`, including construction, copying, serialization, and deserialization.
   * Simplified the domain-to-legacy settings adapter by removing its database-version parameter.
   * Updated adapter tests to reflect settings models without schema metadata.

6. **Database constants and schema definitions**

   * Changed the native SQLite database version from `1` to `1006`.
   * Removed the settings schema-version column constant and excluded that column from new settings tables.
   * Deleted the historical `MigrationSqlScripts` implementation and its incremental SQL migration definitions.
   * Deleted the legacy `DatabaseMigration` coordinator that depended on settings-managed version state.

7. **`lib/store/database/database_provider.dart`**

   * Replaced direct use of `DatabaseManager` with the injectable `DatabaseService`.
   * Propagated database opening failures through the existing `Result` contract.
   * Removed settings-based version checks, migration execution, backup restoration, and legacy migration orchestration from application initialization.
   * Preserved application settings initialization after the database becomes available.

8. **Database and settings service tests**

   * Added coverage for identifiable backups, source preservation, and missing-source failures.
   * Added database lifecycle tests for connection reuse, foreign-key configuration, schema delegation, native version `1006`, opening failures, closing, and reopening.
   * Added coverage for backing up and replacing incompatible databases while leaving current-version databases unchanged.
   * Added settings service tests for missing records, domain-model mapping, default insertion, generated IDs, updates, absent schema metadata, failed updates, and database-opening error propagation.

9. **`doc/backlog/003-persistencia-e-repositories-tasks.md`**

   * Marked the data-layer boundary, database lifecycle, schema-version consolidation, backup fallback, and settings-service tasks as completed.
   * Clarified that legacy database and settings components remain temporarily until their remaining consumers are migrated.
   * Recorded that new implementations enforce persistence isolation while legacy exceptions will be removed in later tasks.

10. **`Changelog.md`**

   * Added the `bkl003/task01` entry documenting the persistence backlog architecture and execution plan.
   * Recorded the dependency-injection, repository-cache, database recovery, legacy-adapter, validation, and backlog-closure requirements established by that planning work.

### Conclusion

The application now has an injectable persistence foundation with centralized database lifecycle management, schema creation, backup-based incompatible-database replacement, and domain-oriented settings access.

SQLite versioning is consolidated at version `1006`, settings are decoupled from schema metadata, and the new data-layer boundaries are documented and covered by focused tests.

## 2026/08/13 - bkl003/task01

This change converts the persistence and repository backlog into an implementation-ready plan. It finalizes the architecture for injectable data services, repository-owned caches, centralized dependency composition, and controlled handling of incompatible local databases.

The backlog documentation now reflects the agreed boundaries between ViewModels, repositories, data services, and SQLite, with a detailed task sequence covering implementation, legacy integration, testing, validation, and closure.

1. **`doc/backlog/003-persistencia-e-repositories-tasks.md`**

   * Added a comprehensive execution checklist for establishing the `data/services` and `data/repositories` structure.
   * Defined the database lifecycle service, including injector-managed singleton scope, connection reuse, foreign-key activation, schema creation, and result-based error handling.
   * Specified the consolidation of database versioning around native schema version `1006`, with backup and controlled fallback for incompatible databases.
   * Planned the migration of settings, users, trainings, and histories from legacy Stores to injectable data services.
   * Defined transactional history deletion behavior, including duration transfer, validation, and rollback requirements.
   * Established repository cache ownership, immutable cache exposure, and synchronization rules for successful and failed persistence operations.
   * Documented `AutoInjector` registrations and prohibited hidden dependency lookup or internal construction of persistence dependencies.
   * Defined temporary legacy-manager adapters that delegate to repositories without retaining duplicate caches.
   * Added cleanup checks for obsolete Stores, historical migration mechanisms, persistence leakage, service-locator access, and duplicated state.
   * Added formatting, testing, analysis, manual validation, documentation, and backlog-closure requirements.
   * Recorded explicit dependencies and expected outcomes for all twelve implementation stages.

2. **`doc/backlog/003-persistencia-e-repositories.md`**

   * Linked the backlog overview to the new implementation task document.
   * Replaced the proposed DAO boundary with data services responsible for SQLite CRUD and record-to-model conversion.
   * Refined the scope to preserve the current schema while encapsulating schema management, transactions, migrations, and backup.
   * Closed the previously open architectural questions and updated the acceptance criteria for services, repositories, backup behavior, and incompatible databases.
   * Documented constructor-only dependency injection with `AutoInjector` as the sole composition root and the database lifecycle service registered as a singleton.
   * Assigned application data caches to repositories while keeping presentation and interaction state in ViewModels.
   * Defined managers as temporary injected compatibility adapters without independent caches.
   * Unified database versioning on native `sqflite` version `1006`, removing parallel settings-based version control and historical migration support.
   * Established backup-before-replacement and controlled bootstrap failure behavior without process termination.
   * Updated the backlog status from planned to tasks defined.

3. **`Changelog.md`**

   * Added the `bkl002/task11` changelog entry covering completion of the pure-domain backlog.
   * Documented domain training-event generation, legacy adapters, stopwatch and report integration, presentation mapping and formatting, expanded tests, architecture updates, dependency maintenance, and Android Kotlin DSL modernization.
   * Recorded closure of backlog 002 and the resulting foundation for persistence backlog 003.

### Conclusion

The persistence backlog now has a complete architectural direction and an ordered implementation plan. It establishes explicit dependency injection, SQLite isolation within data services, repository-owned caches, and recoverable handling of incompatible databases.

The changelog also records the completed domain-layer work that this persistence migration builds upon.

## 2026/08/13 - bkl002/task11

This change completes the pure-domain backlog by connecting the new domain types and training-event generation rules to the legacy application through temporary adapters and presentation mappers. Training reports and speed calculations now delegate to reusable domain services while preserving existing application-facing APIs and formatting behavior.

The change also modernizes the Android build configuration, records the completed architectural transition, closes backlog 002, and adds coverage for domain generation, legacy compatibility, mapping, validation, and presentation formatting.

1. **Android build configuration**

   * Migrated the app, root build, and settings scripts from Groovy to Kotlin DSL.
   * Updated the Android Gradle Plugin to 9.0.1, Kotlin to 2.3.20, and the Gradle wrapper to 9.1.0.
   * Replaced locally parsed Flutter version values and fixed SDK levels with Flutter-provided configuration values.
   * Updated Java and Kotlin compilation targets from JVM 1.8 to JVM 17.
   * Preserved release keystore loading and full native debug-symbol generation.
   * Migrated build-directory and clean-task configuration to the Gradle layout API.
   * Increased Gradle memory limits and retained the Flutter template compatibility flags for the new DSL and built-in Kotlin behavior.
   * Removed obsolete Jetifier and resource-generation compatibility properties.
   * Added Android CMake output to `.gitignore` and updated the reference-keystore documentation link.

2. **`lib/domain/common/training/services/training_event_generator.dart`**

   * Added a stateless domain service that converts a persisted training and its history entries into an immutable sequence of start, split, and lap events.
   * Preserved event ordering and split-per-lap rounding behavior.
   * Accumulated all split durations within each lap and used the accumulated duration for lap speed and event data.
   * Reset lap accumulation between completed laps and between generator calls.
   * Returned an empty immutable event list for empty histories and treated the first history entry as the session start without calculating speed.
   * Added validation for missing training persistence identity, histories belonging to another training, invalid split-to-lap ratios, and zero-duration measurements.
   * Delegated split and lap speed calculations to `SpeedCalculator` and propagated domain failures through `Result`.

3. **`lib/common/adapters`**

   * Added bidirectional adapters between legacy and domain user, training, history, and settings models.
   * Preserved persistence identifiers, dates, comments, measurements, limits, units, locale preferences, refresh intervals, and tutorial settings across conversions.
   * Parsed persisted distance and speed symbols through typed domain units and returned validation failures for unsupported or invalid values.
   * Kept training colors at the legacy UI boundary and database schema metadata outside the domain settings model.
   * Documented the adapters as temporary compatibility bridges for removal during the corresponding persistence, settings, and user migrations.

4. **Legacy stopwatch and training-report integration**

   * Refactored `StopwatchFunctions.speedCalc` to convert legacy training data and delegate typed calculations to `SpeedCalculator`.
   * Converted elapsed seconds to a `Duration` and exposed domain validation failures, including zero elapsed time, through `AppError`.
   * Refactored `TrainingReport` to generate neutral domain events and map them back to legacy `MessagesModel` instances.
   * Removed duplicated report state, speed calculations, and split/lap message construction from the legacy implementation.
   * Preserved the existing `getIndex` API used by active stopwatch code while adding protection for non-positive split counts.
   * Ensured repeated report generation replaces previous messages instead of accumulating stale output.

5. **`lib/common/presentation`**

   * Added `TrainingEventMessageMapper` to convert neutral start, split, and lap events into presentation-facing messages.
   * Kept localized start text, visual color, message types, legacy speed values, and `Split[n]` and `Lap[n]` labels outside the domain.
   * Added `TrainingValueFormatter` for duration and speed display formatting.
   * Preserved the existing duration output, including its historical formatting for durations above one hour, and retained two-decimal speed formatting at the presentation boundary.
   * Updated `StopwatchFunctions.formatDuration` to delegate to the presentation formatter.

6. **Domain and compatibility tests**

   * Added generator tests for empty history, start events, incomplete and completed laps, multiple laps, accumulated lap durations, repeated calls, rounded split ratios, persistence requirements, training ownership, and zero-duration failures.
   * Added adapter round-trip tests for users, trainings, histories, and settings, including unknown units, zero durations, UI colors, and schema metadata boundaries.
   * Added legacy stopwatch tests covering metric calculations, imperial conversion, and zero-elapsed-time errors.
   * Added legacy report integration tests covering message ordering, split and lap labels, accumulated lap duration, and continued `getIndex` compatibility.
   * Added presentation mapper and formatter tests for localized start messages, event labels, colors, message types, duration output, and two-decimal speed display.

7. **Architecture and backlog documentation**

   * Expanded the current architecture document with the delivered core and pure-domain foundations, dependency boundaries, temporary adapter strategy, and current legacy coexistence model.
   * Marked backlog 002 as completed and moved its backlog and task documents into `doc/backlog/closed`.
   * Completed the remaining event-generation, presentation-boundary, adapter, purity, verification, and closure checklist items.
   * Recorded the delivered domain capabilities, validation results, temporary adapters, preserved formatting behavior, and manual emulator-validation limitation.
   * Updated backlog navigation so persistence backlog 003 now depends on completed backlogs 001 and 002.
   * Corrected links between closed backlog documents and standardized “Viewmodel” terminology in the MVVM restructuring plan.

8. **`Changelog.md`**

   * Added the task06 changelog entry documenting the immutable domain entities, validation rules, temporal snapshots, training events, tests, and completed domain-purity backlog work.

9. **Project dependencies and formatting**

   * Moved `mockito` from runtime dependencies to development dependencies and updated it from 5.4.4 to 5.6.4.
   * Normalized trailing whitespace in license headers across PDF, sharing, stopwatch, backup, table-creation, and migration utilities without changing their behavior.

### Conclusion

The pure-domain backlog is now closed with domain training-event generation connected to the legacy application through explicit compatibility and presentation boundaries. Speed and report rules have a single reusable implementation while existing UI-facing models, labels, colors, and formatting remain supported.

The Android project has also been migrated to current Kotlin DSL, Java 17, Kotlin, Android Gradle Plugin, and Gradle configurations, with comprehensive tests and documentation recording the resulting architecture and migration status.

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
