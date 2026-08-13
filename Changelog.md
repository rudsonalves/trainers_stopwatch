# Changelog

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
