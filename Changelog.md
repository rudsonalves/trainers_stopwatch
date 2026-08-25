# Changelog

## 2026/08/25 - bkl009/task-05

This change introduces domain contracts and concrete platform adapters for rendering, storing, sharing, and emailing training reports. The reporting flow now exposes deterministic, testable service boundaries that return `Result` values and avoid coupling domain interfaces to Flutter, repositories, localization providers, or platform plugins.

PDF generation preserves the existing report structure while moving asset loading, locale-aware formatting, and document composition into a dedicated renderer. Temporary file operations and external integrations are isolated behind injectable implementations with consistent error mapping.

1. **`lib/domain/common/report/services`**

   * Added `TrainingReportPdfRenderer`, which accepts prepared report content and presentation texts and returns PDF bytes through `AsyncResult`.
   * Added `TrainingReportPdfTexts` to carry locale and report labels independently of Flutter localization, with value equality and hash-code support.
   * Added `TemporaryReportFileStorage` for writing and idempotently deleting temporary report files through abstract file references.
   * Added `TemporaryReportFile` metadata with value equality, avoiding exposure of `dart:io.File` across service boundaries.
   * Added `ReportShareService` to share a temporary file and subject without transferring file ownership.
   * Added `ReportEmailService` and `ReportEmailMessage` for HTML email delivery with recipients and attachments.
   * Protected email recipient and attachment collections through defensive copies and immutable lists.
   * Standardized asynchronous service results on `Result`/`AppError`.

2. **`lib/data/services/reports/training_report_pdf_renderer_impl.dart`**

   * Added the concrete PDF renderer using the configured stopwatch icon and IBM Plex Mono font assets.
   * Initialized locale date symbols and applied locale-aware date and time formatting at the rendering boundary.
   * Generated one PDF page per training section, including user details, training totals, lap and split configuration, event rows, speeds, durations, and comments.
   * Added Unicode-capable text rendering and preserved valid PDF output for empty reports.
   * Kept rendering independent from repositories and filesystem operations by returning document bytes directly.
   * Converted asset-loading, PDF-generation, and other rendering exceptions into diagnostic `AppError` failures.

3. **`lib/data/services/reports/temporary_report_file_storage_impl.dart`**

   * Added temporary-directory storage for rendered report bytes.
   * Sanitized suggested filenames by removing path components and rejected invalid names or empty MIME types.
   * Generated unique filenames from timestamps and sequence values to prevent collisions between concurrent operations.
   * Returned abstract file metadata after flushed writes and implemented idempotent deletion for existing or already-removed files.
   * Mapped directory, write, and deletion failures to storage-related `AppError` results.
   * Added injectable directory and suffix providers for deterministic testing.

4. **`lib/data/services/reports/report_share_service_impl.dart` and `report_email_service_impl.dart`**

   * Added a `share_plus` adapter that converts temporary report metadata into an `XFile` and forwards the supplied subject without deleting or otherwise owning the file.
   * Added a `flutter_email_sender` adapter that converts domain email messages into HTML emails with recipients, subject, body, and attachment paths.
   * Added injectable plugin functions to isolate platform dependencies in tests.
   * Converted sharing and email plugin exceptions into `AppError` failures while retaining the original error as diagnostic details.

5. **`pubspec.yaml` and `pubspec.lock`**

   * Promoted `intl` to a direct application dependency for locale initialization and localized date formatting in the PDF renderer.
   * Updated the lockfile dependency classification while retaining version `0.20.2`.

6. **`test/domain/common/report/services/report_service_contracts_test.dart`**

   * Added coverage for value equality and hash codes on temporary file metadata, PDF text values, and email messages.
   * Verified defensive copying and immutability of email recipients and attachments.

7. **`test/domain/common/report/services/reports/report_platform_services_test.dart`**

   * Added temporary-storage tests for byte persistence, unique naming, filename sanitization, input validation, failure mapping, and idempotent deletion.
   * Added sharing adapter tests for file metadata and subject conversion, plus plugin exception handling.
   * Added email adapter tests for HTML message conversion, attachment paths, and plugin exception handling.

8. **`test/domain/common/report/services/reports/training_report_pdf_renderer_impl_test.dart`**

   * Added PDF rendering tests using real application assets and prepared report content.
   * Verified PDF signatures, Unicode-compatible rendering, multiple training sections, and valid empty-report output.
   * Added asset-loading failure coverage to confirm exceptions are preserved within `AppError` details.

9. **`doc/backlog/009-relatorios-e-compartilhamento-tasks.md`**

   * Marked the report service contract and platform adapter tasks as completed.
   * Documented the delivered boundaries, concrete implementations, ownership rules, error handling, Unicode and localization support, unique temporary storage, and automated coverage.

### Conclusion

The reporting architecture now provides isolated contracts and tested implementations for PDF generation, temporary file lifecycle management, sharing, and HTML email delivery.

These boundaries make platform integrations replaceable and deterministic while preserving report layout, localized formatting, Unicode content, concurrent file safety, and structured failure handling.

## 2026/08/25 - bkl009/task-03

This change establishes the domain-level reporting model and coordinates report construction through a dedicated use case. Report data can now be assembled independently of PDF rendering, localization, persistence models, and platform plugins while preserving established ordering, calculations, and error behavior.

The change also adds characterization coverage for the legacy PDF, email, and sharing flows, providing an executable baseline for the remaining migration work.

1. **`lib/domain/common/report/models`**

   * Added immutable models for complete report content, per-training sections, event-backed rows, and calculated totals.
   * Protected report section and row collections through unmodifiable copies.
   * Implemented value equality and consistent hash codes across the report structure.
   * Represented totals using domain values for distance and average speed alongside duration and lap count.

2. **`lib/domain/common/report/services`**

   * Added `TrainingReportInput` to associate a training with an immutable history collection.
   * Added `TrainingReportContentBuilder` to convert users, trainings, and history entries into renderer-independent report content.
   * Reused `TrainingEventGenerator` and `SpeedCalculator` to preserve domain semantics for event ordering, splits, laps, distance, duration, and average speed.
   * Preserved input training order and converted generated events into report rows.
   * Propagated domain failures through `Result` and prevented partially built reports from being returned after an error.

3. **`lib/domain/usecases/reports/build_training_report_use_case.dart`**

   * Added `BuildTrainingReportUseCase` with constructor-injected `HistoryRepository` and report content builder dependencies.
   * Validated that the selected user and trainings have persisted identities and that every training belongs to the selected user.
   * Loaded histories sequentially in the received training order before delegating report assembly to the domain builder.
   * Stopped processing on the first repository or content-building failure without exposing partial report content.
   * Supported empty training selections without repository access.

4. **`test/domain/common/report`**

   * Added tests for report model value equality, hash-code consistency, defensive collection copying, and immutability.
   * Verified empty reports, training order, generated event rows, split and lap semantics, totals, units, durations, comments, and average-speed calculations.
   * Covered empty and invalid histories, the preserved `zeroElapsedTime` failure, invalid timelines, and atomic failure behavior.

5. **`test/domain/usecases/reports/build_training_report_use_case_test.dart`**

   * Added use-case coverage for ordered history loading and ordered report output.
   * Verified empty report generation without repository access.
   * Covered transient users, transient trainings, and trainings assigned to another user.
   * Confirmed that repository and builder failures stop processing and return no partial content.

6. **`test/common/functions/report_sharing_characterization_test.dart`**

   * Added characterization tests for legacy report event ordering, labels, units, durations, speeds, comments, and reports without rows.
   * Exercised real PDF generation with a controlled temporary-directory provider, including ordered history loading, non-empty output, zero-page empty reports, and the `zeroElapsedTime` edge case.
   * Captured the existing HTML email subject, recipient, body, attachment, and successful attachment cleanup behavior.
   * Captured the existing sharing subject and PDF metadata, including retention of the temporary shared file.
   * Added fake repository and platform implementations to isolate external integrations while preserving observable behavior.

7. **`pubspec.yaml` and `pubspec.lock`**

   * Added the email sender, path provider, and sharing platform interfaces as direct development dependencies.
   * Enabled characterization tests to replace platform integrations with deterministic fakes.

8. **`doc/backlog/009-relatorios-e-compartilhamento-tasks.md`**

   * Marked the characterization, report content modeling, and report-building use-case tasks as complete.
   * Documented the delivered models, calculations, ordering guarantees, validations, failure boundaries, and platform cleanup behavior.
   * Recorded focused and full test results, static analysis, and diff validation outcomes.
   * Retained remaining exception normalization work for later rendering and platform tasks.

9. **`doc/backlog/009-relatorios-e-compartilhamento.md` and `Changelog.md`**

   * Updated backlog progress to record completion of the legacy behavior characterization.
   * Added the task 1 changelog entry describing the executable reporting and sharing baseline.

### Conclusion

Reporting now has immutable domain content models and a coordinated use case that loads histories, validates ownership, preserves ordering, and returns structured failures without partial output.

Comprehensive domain and legacy characterization tests protect calculations, PDF generation, and external delivery behavior as the reporting architecture continues to be separated from rendering and platform integrations.

## 2026/08/25 - bkl009/task-01

This change establishes the executable characterization baseline for the
reporting and sharing migration. Tests now preserve the legacy report rows,
ordering, PDF production, HTML email payload, sharing metadata, temporary-file
behavior, and empty-input edge cases before architectural separation begins.

1. **Report and sharing characterization**

   * Added focused tests for event order, labels, units, durations, speeds, and
     comments produced by the legacy report.
   * Exercised real PDF generation with a fake temporary-directory provider and
     verified training load order, non-empty output, and the zero-page empty
     report behavior.
   * Recorded the existing `zeroElapsedTime` failure for a training containing
     only its initial marker.
   * Captured the HTML email subject, recipient, body, attachment, and successful
     cleanup through a fake email platform.
   * Captured the sharing subject and PDF attachment through a fake sharing
     platform, including the legacy behavior that leaves the temporary file in
     place.
   * Declared the email, path-provider, and sharing platform interfaces as
     explicit development dependencies used by the test fakes.

2. **Backlog tracking**

   * Marked task 1 complete and documented the observed error boundaries that
     later tasks will normalize to `AppError`.
   * Recorded successful focused and full test runs with 293 passing tests,
     clean static analysis, and diff validation.

### Conclusion

The legacy behavior is now protected by deterministic tests, allowing report
content and platform integrations to be separated in subsequent tasks without
silently changing this version's output or edge cases.

## 2026/08/25 - bkl009/tasks

This change set closes the multiple-stopwatch sessions backlog and starts the reporting and sharing backlog. It records the architectural decisions for the upcoming refactor and introduces a detailed execution plan covering report content, platform integrations, use cases, presentation, dependency injection, legacy removal, and validation.

It also adds workspace configuration so the Android project is recognized as a nested Gradle project.

1. **`.vscode/settings.json`**

   * Added VS Code workspace configuration identifying `android` as a nested Gradle project.

2. **`doc/backlog/009-relatorios-e-compartilhamento.md`**

   * Resolved all previously open questions about PDF pagination, temporary-file ownership, localized HTML email content, empty reports, and trainings without split data.
   * Established that use cases own and clean up temporary files, including after sharing failures.
   * Changed the backlog state from planned to in progress.
   * Linked the backlog to its new task execution plan.

3. **`doc/backlog/009-relatorios-e-compartilhamento-tasks.md`**

   * Added the implementation plan for separating report content, PDF rendering, temporary storage, email, and sharing behind injectable boundaries.
   * Defined tasks for characterizing existing behavior and creating immutable, platform-independent report data.
   * Planned use cases for loading histories, assembling reports, rendering PDFs, invoking external channels, and reliably cleaning up temporary files.
   * Specified contracts and adapters for PDF generation, temporary storage, email, and sharing with `Result` and `AppError`-based failure handling.
   * Defined the migration of `TrainingsViewModel` and `TrainingsPage` to typed Commands without direct repository, renderer, filesystem, or plugin access.
   * Documented dependency-injection, routing, localization, and presentation-boundary updates.
   * Planned removal of legacy report implementations, domain adapters, models, and obsolete integration arguments after consumer migration.
   * Added test coverage requirements for report content, ordering, failures, cleanup ownership, concurrency, Commands, widgets, and platform adapter isolation.
   * Established formatting, testing, static analysis, diff validation, manual integration checks, documentation, and closure requirements.

4. **`doc/backlog/closed/008-sessoes-multiplos-cronometros-tasks.md`**

   * Moved the backlog 008 task plan into the closed backlog folder.
   * Marked manual validation of multiple stopwatches, active-measurement navigation, write failure and retry behavior, and removal paths as completed.
   * Marked the final backlog and task-file archival step as completed.

5. **`doc/backlog/closed/008-sessoes-multiplos-cronometros.md`**

   * Moved the completed multiple-stopwatch sessions backlog into the closed backlog folder without changing its content.

### Conclusion

Backlog 008 is now formally closed and archived after completing its remaining validation requirements. Backlog 009 has entered execution with approved behavioral decisions and a comprehensive implementation and verification plan.

The project workspace also now recognizes the Android module as a nested Gradle project.

## 2026/08/24 - bkl008/task-06

This change completes the automated migration of stopwatch coordination to the session-based MVVM architecture. Legacy page and stopwatch controllers, temporary managers, and their dependency registrations were removed in favor of domain models, `StopwatchSessionViewModel`, and `StopwatchPageViewModel`.

Dependency composition now reuses registered training use cases, while expanded session and widget tests cover isolation, persistence failures, removal workflows, stable session identity, message projection, and recoverable UI errors. Backlog documentation records the completed automated validation and the remaining manual acceptance work.

1. **`lib/core/config/dependencies/`**

   * Removed registrations and imports for `StopwatchPageController`, `PreciseStopwatchController`, `TrainingManager`, and `HistoryManager`.
   * Refactored session ViewModel construction to resolve `CreateTrainingUseCase` and `PersistStopwatchSnapshotUseCase` from the injector instead of constructing them from repositories.
   * Preserved the session factory composition around domain `User` and `Training` instances, `StopwatchBloc`, application settings, and the configured session color.

2. **Legacy stopwatch controllers**

   * Deleted `lib/features/stopwatch_page/stopwatch_page_controller.dart`, removing the legacy user-list, stopwatch-count, and global history-message coordination layer.
   * Deleted `lib/features/widgets/precise_stopwatch/precise_stopwatch_controller.dart`, removing its parallel timer state, legacy model adapters, manager-based persistence, global message publication, and circular dependency on the page controller.
   * Consolidated stopwatch lifecycle and persistence responsibilities under the session ViewModel architecture represented by the remaining application and UI components.

3. **`lib/manager/`**

   * Deleted `HistoryManager` and `TrainingManager`.
   * Removed the temporary repository-to-legacy-model bridges used for session history and training operations.
   * Eliminated the secondary session architecture that performed loading, insertion, updates, deletion, and adapter conversions outside the new ViewModels and use cases.

4. **`test/application/stopwatch/session/stopwatch_session_view_model_test.dart`**

   * Added training-insert failure control to the fake repository and verified that a failed training creation leaves the stopwatch idle, without a persisted training identity or emitted messages.
   * Added page coordination coverage for duplicate athlete rejection, stable session instances, active user identities, and isolation between athletes.
   * Covered direct removal of idle and synchronized finished sessions, cancellation of active removal, and confirmed removal while running or paused.
   * Verified that final-persistence failures retain the finished session with a pending write, and that retrying the write enables subsequent removal.
   * Added assertions that removing one session closes only its BLoC and removes only its messages from the globally ordered projection.

5. **`test/features/widgets/precise_stopwatch/stopwatch_state_widgets_test.dart`**

   * Added widget coverage for recoverable training-creation errors, including visible error feedback and preservation of the idle stopwatch state.
   * Verified that dismissible actions delegate removal by session identity and editing with the session ViewModel rather than transporting a widget.
   * Added active-session dismissal coverage to confirm that the removal dialog is displayed and cancellation preserves the running session.
   * Added focused create-training and snapshot-persistence test implementations to support success and failure scenarios.

6. **`test/core/config/dependencies_test.dart`**

   * Replaced legacy `PreciseStopwatchController` resolution assertions with `StopwatchPageViewModel` resolution.
   * Verified that the page ViewModel is registered as a stable singleton while existing transient dependency behavior remains covered.
   * Removed controller disposal handling made obsolete by the deleted legacy dependency.

7. **`doc/backlog/008-sessoes-multiplos-cronometros-tasks.md`**

   * Marked the MVVM composition and navigation migration tasks as completed.
   * Recorded completion of legacy controller and manager removal, adapter cleanup within the session flow, migration-comment updates, and consumer searches.
   * Marked session coordination, persistence, idempotency, removal, message projection, and widget test requirements as completed.
   * Recorded successful formatting, focused and complete test execution, static analysis, diff validation, architecture searches, and backlog tracking updates.
   * Left manual multi-stopwatch validation and final movement to the closed backlog pending.

8. **`doc/backlog/008-sessoes-multiplos-cronometros.md`**

   * Updated the backlog status to report completion of implementation and automated validation.
   * Documented removal of the legacy controllers, managers, and injector registrations, along with adoption of domain models and session/page ViewModels.
   * Clarified that legacy adapters remain only for verified consumers outside the session flow.
   * Recorded 286 passing tests, clean analysis and diff checks, and the manual scenarios still awaiting maintainer validation.

### Conclusion

The stopwatch flow now relies on a single session-based MVVM architecture, with legacy coordination controllers and temporary managers removed from both implementation and dependency injection.

Automated coverage validates isolated multi-athlete sessions, failure-safe persistence, removal and retry behavior, ordered messaging, and widget interaction. The implementation is automated-test complete, with final backlog closure awaiting manual acceptance validation.

## 2026/08/24 - bkl008/task-05

This change completes the stopwatch presentation migration to session-oriented view models. Stopwatch pages, widgets, navigation, training configuration, and global messages now derive their behavior from `StopwatchPageViewModel` and `StopwatchSessionViewModel` instead of widget-owned controllers and legacy presentation models.

The update also centralizes session creation in dependency injection, preserves per-athlete widget identity, exposes persistence feedback and retry actions, and updates routing and tests for the new architecture.

1. **`lib/application/stopwatch/session/stopwatch_session_view_model.dart`**

   * Made the session color mutable while preserving a public read-only accessor.
   * Extended training updates to accept an optional color value so training configuration and visual presentation state can be updated through the session view model.

2. **`lib/core/config/dependencies.dart` and `lib/core/config/dependencies/viewmodels_dependencies.dart`**

   * Removed legacy stopwatch controller factory configuration from application startup.
   * Registered `StopwatchPageViewModel` as a singleton with a session factory.
   * Added session construction using current settings, domain `Training`, `StopwatchBloc`, training creation and snapshot persistence use cases, repositories, refresh interval, and the default application color.

3. **`lib/main.dart`, `lib/ui/app/my_material_app.dart`, and `lib/core/routing/routes/main_routes.dart`**

   * Replaced application-level `StopwatchPageController` wiring with `StopwatchPageViewModel`.
   * Updated stopwatch and users routes to consume active sessions and user identifiers from the page view model.
   * Updated personal-training navigation to pass the selected session directly and derive history loading from its domain training.
   * Removed legacy training conversion and stopwatch-controller dependencies from route construction.

4. **`lib/core/routing/route_arguments.dart`**

   * Replaced the widget-based personal-training route argument with `StopwatchSessionViewModel`, allowing navigation to share session state without passing a `PreciseStopwatch` widget.

5. **`lib/features/stopwatch_page/stopwatch_page.dart`**

   * Refactored the page to listen to `StopwatchPageViewModel` and render one stopwatch per session.
   * Added stable athlete-based `ValueKey` values for dismissible stopwatch entries.
   * Removed local stopwatch creation, page-controller disposal, and local message accumulation.
   * Rendered the global log directly from the page view model’s message projection.
   * Delegated removal eligibility and confirmed removal to the page view model, including presentation of removal failures.
   * Updated personal-training navigation to pass the selected session and simplified the add-user flow.

6. **`lib/features/stopwatch_page/stopwatch_page_controller.dart`**

   * Removed stopwatch widget ownership, stopwatch controller factory configuration, and legacy add/remove stopwatch operations.
   * Retained only the remaining legacy user and message state still represented by the controller.

7. **`lib/features/stopwatch_page/widgets/stopwatch_dismissible.dart`**

   * Converted the dismissible wrapper from a stateful widget to a stateless session-driven widget.
   * Replaced `PreciseStopwatch` and numeric user arguments with `StopwatchSessionViewModel` and `StopwatchSessionId`.
   * Delegated removal confirmation behavior to the page flow and management navigation to the selected session.
   * Used stable user-based keys and constructed `PreciseStopwatch` directly from the session.

8. **`lib/features/stopwatch_page/widgets/message_row.dart`**

   * Migrated log rendering from the legacy `MessagesModel` to `StopwatchSessionMessage`.
   * Selected icons from typed session message events instead of parsing comment text.
   * Added domain-aware duration and speed formatting for split and lap messages.
   * Derived row colors from the session message color value.

9. **`lib/features/widgets/precise_stopwatch/precise_stopwatch.dart`**

   * Rebuilt `PreciseStopwatch` as a stateless observer of `StopwatchSessionViewModel`.
   * Removed controller initialization, disposal, legacy user models, cloned-widget behavior, and widget-owned notifiers.
   * Rendered user identity, training color, lap limits, display, counters, and controls directly from session state.
   * Routed training edits through the session’s `updateTraining` method.

10. **`lib/features/widgets/precise_stopwatch/widgets/stopwatch_button_bar.dart` and `lap_split_counters.dart`**

   * Replaced legacy controller callbacks with session operations for starting, resuming, pausing, splitting, recording laps, resetting, finishing, and retrying pending writes.
   * Disabled stopwatch actions while session operations are running.
   * Added visible progress, pending-write retry, and recoverable error indicators.
   * Simplified lap-limit rendering to accept the session’s current maximum lap value directly.

11. **`lib/features/widgets/edit_training_dialog/edit_training_dialog.dart`**

   * Migrated the dialog from mutable legacy `TrainingModel` data to immutable domain `Training`.
   * Added `TrainingEditResult` to return the updated training and selected color to the session.
   * Constructed validated distance units, speed units, distances, and training values when applying edits.
   * Kept dialog controllers and `ValueNotifier` instances local to presentation and completed their disposal.
   * Updated field initialization and rendering for domain training properties.

12. **`lib/features/widgets/common/custon_icon_button.dart`**

   * Constrained button labels to a single line with ellipsis overflow to preserve the stopwatch control layout.

13. **`lib/ui/pages/personal_training/personal_training_page.dart`**

   * Replaced the passed stopwatch widget with the shared stopwatch session.
   * Rendered the session-backed stopwatch directly and used the session user for the page title.
   * Reloaded history when the session message count changes and removed the session listener during disposal.

14. **`lib/ui/pages/users/users_page.dart`**

   * Replaced the legacy stopwatch controller dependency with `StopwatchPageViewModel`.
   * Added selected domain users directly to the page view model when leaving the selection page, removing legacy user conversion.

15. **`test/core/routing/routes_test.dart` and `test/features/widgets/precise_stopwatch/stopwatch_state_widgets_test.dart`**

   * Updated route tests to use the injected stopwatch page view model.
   * Migrated widget tests to domain users, domain training, stopwatch sessions, and snapshot persistence use cases.
   * Replaced the controller-initialization test with direct session rendering coverage.
   * Added coverage confirming that the stopwatch page builds session widgets with stable athlete keys.
   * Updated counter tests for the direct maximum-lap value API and removed obsolete legacy controller and manager mocks.

16. **`doc/backlog/008-sessoes-multiplos-cronometros-tasks.md`**

   * Marked the stopwatch presentation migration tasks as completed, covering session-driven widgets, stable identities, session-owned operations, presentation-only dialog state, delegated removal, projected global logs, and persistence feedback.

### Conclusion

The stopwatch interface now operates on application-level session view models throughout dependency injection, routing, user selection, stopwatch controls, training editing, personal-training history, and global logging.

This removes widget ownership of temporal controllers, establishes stable per-athlete session rendering, and exposes synchronized operation, error, and retry state through the presentation layer.

## 2026/08/24 - bkl008/task-04

This change adds safe stopwatch session removal to the page view model. It introduces confirmation handling for active sessions, preserves sessions when final persistence fails, and prevents concurrent removal operations for the same session.

The related backlog task was updated to reflect completion of the removal lifecycle requirements.

1. **`lib/ui/pages/stopwatch/stopwatch_page_view_model.dart`**

   * Added tracking for sessions currently being removed and exposed `isRemoving()` so the UI can reflect or restrict in-progress removal operations.
   * Added `requiresRemovalConfirmation()` to identify running and paused sessions that require explicit user confirmation.
   * Added `removeSession()` with validation for closed view models, missing sessions, duplicate removal requests, and unconfirmed active-session removal.
   * Added graceful finishing of confirmed running or paused sessions before removal.
   * Prevented sessions with pending writes or failed final persistence from being removed, preserving their state for a later retry.
   * Removed session listeners, collection entries, and session resources only after the session is synchronized and safe to close.
   * Added listener notifications around the removal lifecycle and cleared removal tracking during shutdown.
   * Refactored disposal placement while preserving asynchronous page view-model closure and idempotent notifier disposal.

2. **`doc/backlog/008-sessoes-multiplos-cronometros-tasks.md`**

   * Marked the session-removal task requirements as completed, including confirmation decisions, safe finalization, pending-write preservation, cancellation behavior, disposal ordering, and concurrency protection.

### Conclusion

Stopwatch sessions can now be removed through a guarded lifecycle that protects active timing state and pending persistence work. The page view model exposes the information needed for UI confirmation while retaining responsibility for synchronization, cleanup, and concurrent-operation control.

## 2026/08/24 - bkl008/task-03

This change introduces page-level lifecycle management for stopwatch sessions. The new view model owns active sessions, prevents duplicates, aggregates session messages, propagates updates, and coordinates asynchronous cleanup.

Dependency registration and backlog documentation were updated to integrate and reflect the completed implementation.

1. **`lib/ui/pages/stopwatch/stopwatch_page_view_model.dart`**

   * Added `StopwatchPageViewModel` as the owner of stopwatch sessions while the application is active.
   * Added an injectable `StopwatchSessionFactory` for creating session view models from users.
   * Stored sessions in insertion order using stable `StopwatchSessionId` identities.
   * Added immutable accessors for active user IDs, sessions, and globally aggregated messages.
   * Sorted aggregated messages by their existing temporal ordering.
   * Added user registration with session ID validation and duplicate prevention.
   * Forwarded session changes through the page view model's listener notifications.
   * Added idempotent asynchronous shutdown that removes listeners, closes every session, and disposes the notifier.
   * Rejected new users after shutdown with an `invalidData` failure.

2. **`lib/core/config/dependencies/viewmodels_dependencies.dart`**

   * Registered `StopwatchPageViewModel` in the view-model dependency configuration.
   * Added the corresponding stopwatch page view-model import.

3. **`doc/backlog/008-sessoes-multiplos-cronometros-tasks.md`**

   * Marked the stopwatch page view-model task requirements as completed.
   * Updated the documented file location to the UI stopwatch page module.

### Conclusion

The stopwatch page now has a centralized, observable owner for persistent session instances and their combined messages. The implementation also establishes dependency injection and coordinated lifecycle cleanup for all active stopwatch sessions.

## 2026/08/24 - bkl008/task-02

This change introduces independent stopwatch sessions for persisted athletes, with immutable session state, stable identities, named lifecycle operations, and presentation messages derived from confirmed stopwatch snapshots.

It also adds idempotent snapshot persistence across the domain, repository, service, and database layers. Snapshot revisions are preserved through retries, duplicate writes with identical content succeed safely, and conflicting content is rejected without overwriting existing history.

1. **`lib/application/stopwatch/session/`**

   * Added `StopwatchSessionId`, using the persisted athlete ID as a stable session identity and rejecting transient users.
   * Added immutable `StopwatchSessionWrite` values containing the training ID, snapshot revision, inferred snapshot type, original snapshot, and comments required for exact retries.
   * Added ordered presentation messages with stable identities based on session, revision, and message type.
   * Added immutable session state covering initialization, persistence, pending writes, messages, recoverable errors, user, and current training.
   * Added `StopwatchSessionViewModel` with an exclusive `StopwatchBloc` and injected training creation, snapshot persistence, speed calculation, and clock dependencies.
   * Implemented named start, pause, resume, reset, split, lap, finish, retry, and training-update operations with transition and concurrency validation.
   * Persisted the training before starting measurement, configured BLoC limits from the persisted training, and published start messages after initialization.
   * Converted each emitted snapshot revision into one immutable pending write, retained it after persistence failures, and reused the exact value during retries.
   * Published split, lap, and finish messages only after successful persistence, including calculated speeds and stable ordering metadata.
   * Added idempotent asynchronous shutdown that waits for active work and closes only the session BLoC while retaining `ChangeNotifier.dispose()` compatibility.

2. **`lib/domain/common/history/models/history_entry.dart`**

   * Added snapshot type and revision fields to retain idempotency metadata in history entries.
   * Added validation requiring snapshot revision and type to be supplied together, with positive revisions.
   * Extended equality and hashing to include snapshot identity metadata.

3. **`lib/domain/usecases/trainings/persist_stopwatch_snapshot_use_case.dart`**

   * Added a use case that maps split, lap, and finish snapshots into history entries.
   * Preserved the snapshot revision and type while selecting the appropriate split duration for persistence.
   * Routed snapshot writes through the repository’s idempotent insertion operation.

4. **History repository and service layer**

   * Extended `HistoryRepository` and `HistoryRepositoryImpl` with idempotent insertion support.
   * Updated repository caching to add returned records only when they are not already cached.
   * Added service-level lookup by training and snapshot revision before insertion.
   * Made identical repeated writes return the existing record successfully.
   * Rejected reused snapshot identities containing different types, durations, or comments.
   * Added conflict recovery for concurrent inserts by re-reading and validating the persisted record.

5. **Database schema and history mapping**

   * Increased the database version from `1006` to `1007`.
   * Added nullable snapshot revision and snapshot type columns so existing history remains compatible.
   * Added a partial unique index over training ID and non-null snapshot revision.
   * Added an explicit `1006` to `1007` migration and rejected unsupported migration paths.
   * Updated database opening to migrate version `1006` instead of replacing it.
   * Updated `HistoryMapper` to serialize and deserialize snapshot identity fields.

6. **`lib/core/config/dependencies/usecases_dependencies.dart`**

   * Registered `PersistStopwatchSnapshotUseCase` in dependency injection alongside the existing training and user use cases.

7. **Stopwatch session tests**

   * Added coverage for persisted-user session identity, immutable writes, deterministic message ordering, immutable message collections, and nullable state updates.
   * Verified that training persistence precedes stopwatch execution.
   * Covered pause, resume, finish, retry, automatic lap-limit completion, message publication, and idempotent session closure.
   * Confirmed that failed writes retain the exact snapshot payload and publish a single success message after retry.

8. **Persistence and migration tests**

   * Added database service coverage for migrating version `1006` to `1007` without deleting the existing database.
   * Added history service coverage for returning identical persisted writes and rejecting conflicting content.
   * Added use-case coverage for mapping snapshot identity and content into an idempotent history write.
   * Updated repository fakes and database expectations for the new idempotent insertion contract and schema version.

9. **`doc/backlog/008-sessoes-multiplos-cronometros-tasks.md`**

   * Marked the session models, idempotent persistence, and session view-model tasks as completed.
   * Refined the retry requirement to explicitly preserve immutable snapshots and comments.
   * Documented the implemented `close()` and `dispose()` lifecycle behavior.

### Conclusion

The application now has an independent session orchestration layer for each athlete, coordinating stopwatch state, training initialization, snapshot persistence, retries, and presentation messages without widget dependencies.

Snapshot writes are idempotent from the session through the database, preserving existing history during migration and preventing duplicate or conflicting partial records. Automated tests cover the new session lifecycle, persistence guarantees, and schema upgrade behavior.

## 2026/08/24 - bkl008/task-01

This change formalizes the implementation plan for migrating stopwatch management to independent MVVM sessions while retaining `StopwatchBloc` as the temporal core.

It also closes the backlog’s architectural questions around navigation, idempotent persistence, safe session removal, and message ownership, and links the backlog to the new execution checklist.

1. **`doc/backlog/008-sessoes-multiplos-cronometros-tasks.md`**

   * Added a phased task plan for modeling stable session identities, immutable operational state, pending snapshot writes, and session-scoped messages.
   * Defined the persistence work required to make snapshot writes idempotent by training ID and `snapshotRevision`, including schema constraints, migrations, retries, and conflicting-content handling.
   * Specified the responsibilities and lifecycle of `StopwatchSessionViewModel` and `StopwatchPageViewModel`, including session ownership, BLoC coordination, global message projection, and asynchronous disposal.
   * Documented safe removal behavior for idle, finished, running, paused, synchronized, and persistence-failed sessions.
   * Planned the migration of widgets, selection flows, routes, dependency composition, and training configuration from legacy controllers and managers to session ViewModels.
   * Defined the removal scope for obsolete controllers, managers, adapters, widget collections, global keys, message channels, and duplicated temporal flags.
   * Added comprehensive testing requirements covering session independence, persistence ordering and retry behavior, navigation, removal confirmation, resource disposal, messaging, and widget integration.
   * Added delivery validation steps for formatting, focused and complete test suites, static analysis, diff verification, manual scenarios, dependency searches, and backlog closure.
   * Established a completion rule requiring independent persistent sessions, stable widget identities, idempotent writes, safe active-session removal, session-owned messages, legacy architecture cleanup, and successful validation.

2. **`doc/backlog/008-sessoes-multiplos-cronometros.md`**

   * Replaced the open architectural questions with confirmation that the decisions were resolved before implementation.
   * Documented that active sessions persist through navigation and are changed only by explicit temporal actions or confirmed disposal.
   * Defined snapshot persistence identity and retry semantics, including reuse of immutable content and successful reconciliation with an existing persisted write.
   * Established confirmation and final-persistence requirements for removing running or paused sessions, while allowing direct removal of idle or synchronized finished sessions.
   * Clarified that persistence failures retain the session and pending write, and that discarding without saving cannot occur implicitly.
   * Assigned messages to individual athlete sessions and defined the global log as a chronological projection of messages from active sessions.
   * Updated the backlog status to in progress and linked it to the newly prepared task plan.

### Conclusion

The backlog now has explicit architectural decisions and an ordered implementation plan for replacing global stopwatch composition with persistent, independent MVVM sessions.

The documented delivery scope covers idempotent persistence, safe lifecycle management, UI and routing migration, legacy cleanup, and deterministic validation.

## 2026/08/24 - bkl007/task-02

This change completes the stopwatch temporal-core migration to an application-layer BLoC backed by `dart:core Stopwatch`. The new immutable state is the single source of elapsed duration, counters, lifecycle status, civil timestamps, and revisioned split, lap, and finish snapshots.

Legacy stopwatch consumers now observe BLoC state directly and coordinate actions deterministically. The delivery also adds comprehensive temporal and widget tests, closes backlog 007, records the remaining session responsibilities for backlog 008, and includes supporting Android build and UI initialization fixes.

1. **`lib/application/stopwatch/bloc`**

   * Added `StopwatchBloc` with explicit run, pause, resume, reset, split, lap, stop, configure, and internal tick events.
   * Replaced wall-clock duration calculations with an injectable `Stopwatch`, using `Stopwatch.elapsed` as the exclusive monotonic duration source.
   * Added injectable civil-time and stopwatch factory callbacks, a configurable visual tick interval, optional lap limits, and validated splits-per-lap configuration.
   * Implemented `idle`, `running`, `paused`, and `finished` transitions, including safe no-op handling for incompatible events.
   * Added split, lap, and finish snapshot production from monotonic elapsed differences, with revision increments for deterministic consumption.
   * Added automatic completion when the configured lap limit is reached.
   * Ensured pause, reset, finish, lap-limit completion, and `close()` cancel the visual ticker and prevent stale ticks from restoring obsolete state.
   * Added immutable `StopwatchState` data, nullable-field clearing through `copyWith`, and value equality across temporal state and configuration.

2. **`lib/bloc`**

   * Removed the legacy stopwatch BLoC, event classes, and state subclasses.
   * Eliminated `DateTime.difference` duration measurement, direct `AppSettings` refresh access, mutable public configuration, parallel `ValueNotifier` counters, and the custom `dispose()` lifecycle.
   * Removed the reset and error state classes in favor of explicit status transitions and safe ignored events.

3. **`lib/features/widgets/precise_stopwatch/precise_stopwatch_controller.dart`**

   * Migrated the legacy controller to the application-layer stopwatch BLoC and revisioned domain snapshots.
   * Replaced mutable BLoC configuration with `StopwatchEventConfigure`.
   * Added explicit resume handling and changed action coordination from fixed 100 ms delays to stream-based state predicates.
   * Updated split, lap, and finish persistence flows to consume snapshot durations exactly once.
   * Switched training start timestamps to immutable BLoC state and standardized cleanup on `bloc.close()`.
   * Preserved training creation, persistence, messaging, and manager coordination outside the temporal BLoC.

4. **`lib/features/widgets/precise_stopwatch`**

   * Updated the stopwatch display and lap/split counters to rebuild from `StopwatchState` through `BlocBuilder`.
   * Simplified `CounterRow` to render plain state values instead of observing individual `ValueNotifier` instances.
   * Updated the button bar to select actions from the four explicit stopwatch statuses and state-based split-cycle configuration.
   * Added asynchronous controller initialization handling with fixed-height loading and error states, preventing training data from being read before initialization completes.
   * Removed direct mutation of the BLoC lap limit from the stopwatch widget.

5. **`lib/features/stopwatch_page/widgets/stopwatch_dismissible.dart`**

   * Updated dismissal protection to use the new stopwatch status model.
   * Continued blocking removal while a stopwatch is running or paused.

6. **`lib/features/widgets/common/user_card.dart`**

   * Wrapped the user tile in a clipped `Material` surface so rounded corners and interaction rendering follow the card shape.
   * Normalized the constants import to the application package-root style.

7. **`test/application/stopwatch/bloc/stopwatch_bloc_test.dart`**

   * Added deterministic coverage using an injectable controlled stopwatch and fake asynchronous time.
   * Verified monotonic ticks, pause and resume behavior, reset and clean restart, split cycles, lap boundaries, running and paused completion, automatic lap-limit completion, and civil timestamps.
   * Verified invalid and repeated events are ignored safely, tickers stop after pause and closure, and separate BLoC instances remain temporally independent.
   * Added state value-equality and nullable-field clearing coverage.

8. **`test/features/widgets/precise_stopwatch/stopwatch_state_widgets_test.dart`**

   * Added widget coverage proving that elapsed duration and counters rebuild from emitted stopwatch state.
   * Added a delayed-controller test confirming that the stopwatch widget displays initialization progress without reading training data prematurely.

9. **`pubspec.yaml` and `pubspec.lock`**

   * Added `fake_async` as a direct development dependency for deterministic ticker and lifecycle testing.

10. **`android/gradle.properties`**

   * Enabled native access for unnamed JVM modules in the Gradle process while preserving the existing memory and diagnostic settings.

11. **`doc/backlog/closed/007-nucleo-cronometro-bloc.md` and `007-nucleo-cronometro-bloc-tasks.md`**

   * Moved the backlog specification and task plan into the closed backlog directory.
   * Updated the temporal dependency design to use injectable callbacks and a private timer instead of ceremonial clock and ticker interfaces.
   * Marked all implementation, integration, testing, and validation tasks complete.
   * Recorded the delivered BLoC behavior, consumer migration, test results, static-analysis outcome, diff validation, and delegated device validation.

12. **`doc/backlog/README.md`, `closed/006-treinos-e-historicos.md`, and `008-sessoes-multiplos-cronometros.md`**

   * Updated backlog navigation to reference the closed backlog 007 documents.
   * Marked backlog 007 as a completed dependency of backlog 008.
   * Documented the remaining temporary responsibilities in `PreciseStopwatchController`, `TrainingManager`, and `HistoryManager` for the future MVVM session migration.

### Conclusion

The stopwatch now has a deterministic, lifecycle-safe temporal core whose immutable BLoC state owns elapsed time, counters, configuration, and action snapshots. Legacy widgets and persistence coordination consume that state without parallel temporal notifiers or fixed processing delays.

Backlog 007 is documented as complete with automated coverage for temporal behavior, resource cleanup, independent stopwatch instances, and state-driven widget updates. Session orchestration and persistence boundaries remain explicitly reserved for backlog 008.

## 2026/08/24 - bkl007/task-01

This change formalizes the implementation plan and resolved design decisions for the BLoC-based stopwatch timing core. It establishes the intended temporal model, lifecycle behavior, legacy integration boundaries, and deterministic testing strategy for backlog 007.

The update also narrows static analysis to project-owned sources and refreshes resolved development and transitive dependencies.

1. **`analysis_options.yaml`**

   * Excluded generated build output and platform-specific Android, iOS, web, Windows, macOS, and Linux directories from analyzer processing.
   * Preserved the existing formatter and lint configuration while focusing analysis on relevant project code.

2. **`doc/backlog/007-nucleo-cronometro-bloc-tasks.md`**

   * Added the detailed execution plan for rebuilding the stopwatch timing core around BLoC and `Stopwatch.elapsed`.
   * Defined injectable contracts for civil time, monotonic stopwatch creation, and visual ticker lifecycle.
   * Specified an immutable state model covering `idle`, `running`, `paused`, and `finished`, with counters, elapsed duration, civil timestamps, snapshots, and monotonic snapshot revisions.
   * Documented the event and transition behavior for starting, pausing, resuming, resetting, recording splits and laps, finishing, and safely ignoring invalid operations.
   * Established lifecycle and concurrency requirements for ticker uniqueness, cancellation, late tick rejection, idempotent operations, and BLoC resource cleanup through `close()`.
   * Planned the minimum legacy consumer adaptations needed to make BLoC state the sole source of timing data while keeping persistence, session coordination, presentation concerns, and write-failure handling outside the timing core.
   * Defined composition-root changes for constructor-based configuration and removal of global settings dependencies.
   * Added a deterministic testing matrix using controllable clock, stopwatch, and ticker fakes, including transition, snapshot, counter, duration, invalid-event, automatic completion, and resource-lifecycle coverage.
   * Added delivery validation requirements covering formatting, focused and complete test suites, static analysis, diff validation, manual flows, multi-stopwatch independence, and backlog closure.

3. **`doc/backlog/007-nucleo-cronometro-bloc.md`**

   * Replaced the open design questions with explicit architectural decisions.
   * Set the default visual update interval to 50 milliseconds while retaining `Stopwatch.elapsed` as the duration source.
   * Defined lap registration as closing both the current lap and split at the same monotonic instant.
   * Allowed finishing from both running and paused states, with paused time excluded from elapsed duration.
   * Defined reset as a transition to a clean `idle` state and finish as a transition to `finished` that preserves final duration, counters, and the `FinishSnapshot`.
   * Linked the backlog to its new detailed execution plan.

4. **`pubspec.lock`**

   * Refreshed resolved versions and integrity hashes for analyzer, build, formatting, code-generation, testing, mocking, platform interop, and supporting transitive packages.
   * Updated the direct development dependency `mockito` from 5.6.4 to 5.8.1.
   * Updated related analyzer and test toolchains, including `analyzer`, `_fe_analyzer_shared`, `dart_style`, `test`, `test_api`, and `test_core`.
   * Updated supporting packages such as `code_assets`, `hooks`, `image`, `intl`, `matcher`, `meta`, `objective_c`, `record_use`, `source_maps`, `synchronized`, `vector_math`, and `vm_service`.

### Conclusion

The change set converts backlog 007 from an open architectural proposal into a concrete, ordered delivery plan with resolved timing semantics and explicit integration and validation boundaries.

It also improves analyzer scope and refreshes the locked dependency toolchain needed for subsequent implementation and testing work.

## 2026/08/20 - bkl006/task-09

This change completes the migration of training and history flows to an MVVM architecture based on domain entities, repositories, Commands, and route-scoped ViewModels. Legacy page controllers, shared history abstractions, UI managers, overlays, and model-based presentation paths were removed where they no longer had consumers.

Routing and dependency composition now construct Pages directly with typed domain arguments and disposable ViewModels. Documentation and tests were updated to close backlog 006, record remaining stopwatch-session and reporting bridges, and verify the migrated behavior.

1. **`lib/ui/pages/history`**

   * Added `HistoryPage` and `HistoryViewModel` using `Training`, `User`, `HistoryEntry`, repository contracts, and Commands.
   * Added loading, comment updates, guarded deletion, adjacent-duration merging, error preservation, and regeneration of splits, laps, and statistics through `TrainingEventGenerator`.
   * Added immutable history statistics and typed comment-update models.
   * Rebuilt history list, dismissible entry, edit dialog, and training information widgets around domain entities and typed callbacks.
   * Kept text controllers, dialogs, gesture confirmation, and navigation concerns within the UI.

2. **`lib/ui/pages/personal_training`**

   * Replaced the legacy personal-training page and controller with a Page backed by `HistoryViewModel`.
   * Connected stopwatch actions to history reloads while preserving reversed event presentation and stopwatch controls.
   * Added explicit listener cleanup and ViewModel disposal for the route lifecycle.

3. **`lib/ui/pages/trainings`**

   * Replaced the legacy training Page, controller, state classes, and widgets with `TrainingsPage`, `TrainingsViewModel`, and domain-oriented widgets.
   * Migrated user selection, training selection, bulk selection, deletion, history navigation, and sharing to `User` and `Training` entities.
   * Added typed callbacks for training rows and user selection while retaining confirmation dialogs and current list interactions.
   * Moved the feature from `lib/features/trainings_page` into the consolidated UI structure.

4. **History and training legacy presentation modules**

   * Removed `HistoryController`, `HistoryPageController`, `PersonalTrainingController`, `TrainingsPageController`, their state types, and the associated model-based Pages and widgets.
   * Removed the legacy shared history list, dismissible history entry, and edit-history dialog after replacing them with domain-based UI components.
   * Removed `UserManager` because the migrated training flow now accesses `UserRepository` through its ViewModel.
   * Retained `TrainingManager` and `HistoryManager` only as temporary stopwatch-session adapters, with removal reassigned to backlog 008.

5. **`lib/core/routing`**

   * Changed history route arguments from legacy models to `User` and `Training` domain entities.
   * Updated route dependencies to accept factories for `TrainingsViewModel` and `HistoryViewModel`.
   * Changed settings, users, trainings, and stopwatch routes to construct their Pages directly.
   * Added domain conversion for personal-training route data before creating its history ViewModel.
   * Removed the settings, users, trainings, and stopwatch overlay wrappers.

6. **Application composition and ViewModel lifecycle**

   * Updated `main.dart`, `MyMaterialApp`, and `MainRouteDependencies` to create route-scoped users, trainings, history, and settings ViewModels through typed callbacks.
   * Removed registrations for legacy training and history page controllers and `UserManager`.
   * Removed the intermediate `UsersViewModelFactory`; users ViewModels are now constructed directly from runtime active-user IDs.
   * Moved ViewModel disposal into the settings, users, trainings, history, and personal-training Pages.
   * Preserved transient creation of stopwatch-session controllers and singleton registration where still required.

7. **Sharing and legacy adapters**

   * Updated `AppShare` to receive domain `User` and `Training` values for email and WhatsApp sharing.
   * Kept conversion to legacy models only at the PDF-generation boundary.
   * Updated adapter documentation to identify their remaining stopwatch-session and report consumers in backlogs 008 and 009.
   * Updated training email content generation to read distance values and units from domain value objects.

8. **Domain, data, bootstrap, and presentation types**

   * Removed `final` class modifiers across affected domain models, value objects, services, repositories, mappers, use cases, ViewModels, formatters, logging, bootstrap, and test fakes.
   * Applied the same class declaration change to route argument and dependency types used by the migrated architecture.
   * Preserved existing constructors, contracts, caching behavior, and service implementations.

9. **Tests**

   * Added comprehensive `HistoryViewModel` tests covering loading, derived splits and laps, statistics, comment updates, deletion with duration merging, invalid deletions, persisted-training requirements, and cache preservation after failures.
   * Expanded routing tests to verify typed domain arguments, direct Page construction, route transitions, and recreation of route-scoped ViewModels.
   * Updated dependency tests to reflect removal of `UsersViewModelFactory` and verify transient stopwatch-session controller creation.
   * Updated existing repository, image, user, training, and ViewModel test fakes to match the revised class declarations.

10. **Architecture and backlog documentation**

   * Updated the current architecture to describe direct Page routing, ViewModel-based presentation state, removal of onboarding overlays, and repository-based training flow.
   * Marked backlog 006 and all remaining tasks as completed, documented delivered behavior and validation results, and moved its planning files into `doc/backlog/closed`.
   * Updated the backlog index and dependent backlog links to reference the closed backlog.
   * Expanded backlogs 008 and 009 with the remaining session-manager, legacy-adapter, report, and sharing migration work.
   * Clarified the earlier users backlog documentation after removal of the users ViewModel factory.

### Conclusion

Training and history presentation now operate through domain entities, repositories, Commands, and disposable ViewModels, removing the legacy controller and manager dependencies from migrated UI flows.

Routes construct Pages directly, sharing accepts domain data at its UI boundary, and the remaining legacy adapters are explicitly limited to future stopwatch-session and reporting migrations. Backlog 006 is documented as complete with corresponding coverage for the new architecture and behavior.

## 2026/08/20 - bkl006/task-05

This change establishes feature-local UI boundaries for migrated pages, introduces command-based training presentation state, and coordinates training initialization with its required history entry.

Settings and users pages now colocate their pages, overlays, ViewModels, form models, and widgets under `lib/ui/pages`. Training creation and selection behavior gain explicit, testable application boundaries, with routing, dependency composition, documentation, and tests updated accordingly.

1. **Training initialization use case**

   * Added `CreateTrainingUseCase` to persist a training before creating its zero-duration initial history entry.
   * Added compensation through training deletion when initial-history creation or persistence fails.
   * Preserved both primary and compensation errors, including the persisted training identity, when rollback fails.
   * Added `TrainingInitialization` as the typed result containing the persisted training and initial history.
   * Rejected successful training insertions that do not return a persistence identity.

2. **Stopwatch training-start flow**

   * Replaced separate training and initial-history writes with `CreateTrainingUseCase`.
   * Converted the legacy training model to its domain representation before initialization.
   * Passed the localized start message into the coordinated initial-history creation.
   * Synchronized the generated training identity back into the legacy model and retained history-manager initialization for subsequent stopwatch operations.
   * Normalized stopwatch widget imports to project-root paths.

3. **TrainingsViewModel**

   * Added a command-based ViewModel backed by `UserRepository` and `TrainingRepository`.
   * Added commands for loading users, loading a selected user’s trainings, updating, deleting, and deleting the current selection.
   * Exposed repository-backed users and trainings while keeping selected-user and selected-training IDs as transient UI state.
   * Added immutable selection access, individual selection, select-all, clear-selection, and derived selected-training state.
   * Reconciled selection after user changes, reloads, deletions, partial batch failures, and removal of the selected user.
   * Consolidated loading and latest-error reporting across commands and disposed command listeners with the ViewModel.

4. **Settings page module**

   * Moved the settings page and overlay from `lib/features/settings` to `lib/ui/pages/settings`.
   * Moved `SettingsViewModel` and `SettingsFormData` into the local `viewmodel` hierarchy.
   * Moved the page-specific length editor into the settings `widgets` directory.
   * Updated bootstrap, routing, dependency registration, page imports, and shared-widget references for the new layout.

5. **Users page module**

   * Moved the users page and overlay from `lib/features/users_page` to `lib/ui/pages/users`.
   * Grouped `UsersViewModel`, its factory, and `UserFormResult` under the local `viewmodel` hierarchy.
   * Moved the dismissible user tile and complete user-dialog widget tree under the users page module.
   * Updated routing, application bootstrap, dependency composition, and internal references to the relocated files.

6. **Dependency composition and routing**

   * Registered `CreateTrainingUseCase` in the use-case dependency module with transient resolution.
   * Updated settings and users ViewModel registrations to their new feature-local paths.
   * Updated main routes to load the migrated settings and users overlays and ViewModels from `lib/ui/pages`.
   * Updated application entry-point and material-app imports to match the reorganized presentation layout.

7. **Automated tests**

   * Added use-case coverage for persistence order, training insertion failure, history insertion failure, successful compensation, failed compensation, and missing persistence identity.
   * Added `TrainingsViewModel` coverage for loading, invalid users, immutable selection, user changes, cache reconciliation, mutations, partial batch deletion, error state, and selected-user removal.
   * Extended dependency-composition coverage to verify transient `CreateTrainingUseCase` resolution.
   * Moved settings and users tests to mirror the new application layout and updated their imports.

8. **Architecture and backlog documentation**

   * Updated the architecture guide to document `lib/ui/pages/<feature>` as the destination for migrated presentation modules while preserving temporary legacy locations.
   * Marked the coordinated training-creation and `TrainingsViewModel` backlog tasks as completed.
   * Documented delivered failure handling, repository boundaries, transient selection behavior, and command-based state management.
   * Added changelog entries covering the training initialization, training ViewModel, and migrated page layout work.

### Conclusion

The change set provides safer training initialization, testable training-list state, and clearer feature-local presentation boundaries. Migrated settings and users modules now follow a consistent UI structure, while dependency composition and routing reflect the new architecture.

## 2026/08/20 - migrated-pages-layout

This change colocates each migrated page with its local ViewModels, form
models, overlays, and widgets under `lib/ui/pages`.

1. **Settings page**

   * Moved the page and overlay to `ui/pages/settings`.
   * Grouped its ViewModel and form model under `viewmodel`.
   * Moved the page-specific length editor under `widgets`.

2. **Users page**

   * Moved the page and overlay to `ui/pages/users`.
   * Grouped the ViewModel, factory, and form result under `viewmodel`.
   * Moved the user tile and complete user-dialog tree under local `widgets`.

3. **Training ViewModel and tests**

   * Placed the new `TrainingsViewModel` in its final `viewmodel` directory
     while leaving the legacy page in `features` until its migration task.
   * Mirrored the application layout in the affected UI tests.
   * Updated routing, dependency composition, bootstrap, and all imports.

### Conclusion

Migrated pages now have feature-local, predictable UI boundaries, while truly
shared legacy components remain separate until UI consolidation.

## 2026/08/20 - bkl006/task-04

This change introduces the command-based `TrainingsViewModel` and moves
training-list presentation state behind a testable MVVM boundary.

1. **TrainingsViewModel**

   * Added injected user and training repository dependencies.
   * Added commands for loading users, loading a selected user's trainings,
     updating, deleting, and deleting the current selection.
   * Exposed repository-backed domain users and trainings without duplicating
     their caches.
   * Consolidated loading and the latest `AppError` across all commands.

2. **Transient UI selection**

   * Added immutable selected-training IDs and derived selected entities.
   * Added individual selection, select-all, and clear operations.
   * Reconciled selection after user changes, reloads, deletions, partial batch
     failures, and removal of the selected user.

3. **Tests**

   * Added coverage for loading, invalid users, immutable selection, user
     changes, cache reconciliation, mutations, partial deletion, error state,
     and removal of the selected user.

### Conclusion

Training-list operations and transient selection are ready for page migration
without managers, legacy models, or widget-owned business state.

## 2026/08/20 - bkl006/task-03

This change makes training initialization a recoverable operation coordinated
across training and history repositories.

1. **Training initialization use case**

   * Added `CreateTrainingUseCase` for inserting a training followed by its
     zero-duration initial history entry.
   * Added cascade-based compensation when initial-history persistence fails.
   * Preserved primary and compensation errors when rollback also fails.
   * Added `TrainingInitialization` as the typed successful result.

2. **Stopwatch integration and composition**

   * Replaced separate legacy writes at timer start with the coordinated use
     case.
   * Kept later split writes and simple operations directly on their existing
     repository boundaries.
   * Registered the use case with transient lifetime and covered it in the
     composition-root test.

3. **Tests**

   * Covered operation order, training failure, history failure, successful
     compensation, failed compensation, and a missing persistence identity.

### Conclusion

Starting a training no longer leaves an orphan training when its fundamental
initial event cannot be persisted.

## 2026/08/20 - bkl006/task-02

This change establishes centralized declarative routing with `go_router`, strengthens training-history domain semantics, and validates repository cache and SQLite relationship contracts.

Application composition, page navigation, typed route arguments, domain event generation, repository tests, and the backlog architecture documentation were updated to reflect the delivered boundaries.

1. **`lib/core/routing`**

   * Added centralized route names and paths for stopwatch, users, trainings, settings, about, personal training, and history.
   * Added a `GoRouter` factory with `/stopwatch` as the initial location, debug diagnostics, and a shared route observer.
   * Added grouped route construction and explicit dependency composition for controllers, ViewModels, and sharing services.
   * Added typed argument classes for personal-training and history navigation.
   * Added a shared fade-and-scale transition with dedicated forward and reverse durations.

2. **Application composition and bootstrap**

   * Migrated `MyMaterialApp` from the Navigator 1.0 route table to `MaterialApp.router`.
   * Created and retained a stable `GoRouter` instance for the application lifecycle and disposed it with the app state.
   * Moved route dependency composition out of the widget build method.
   * Renamed theme contrast helpers as private implementation details.
   * Extracted `BootstrapErrorApp` from `main.dart` into its own UI module.

3. **Feature navigation**

   * Replaced page-level `Navigator.pushNamed` calls with named `go_router` navigation.
   * Passed personal-training and history data through typed route argument objects instead of dynamic maps.
   * Removed duplicated route constants and `ModalRoute` argument factories from feature widgets.
   * Updated the stopwatch drawer to close itself before navigating through the centralized router.
   * Updated the users page to use `go_router` for page dismissal while retaining direct `Navigator.pop` for modal drawer handling.
   * Changed the stopwatch route from `/stopwatchs` to `/stopwatch`.

4. **Training event domain**

   * Added persisted and derived origin metadata to training events.
   * Classified training starts and splits as persisted events and laps as derived events.
   * Added convenience properties for checking whether an event is persisted or derived.
   * Added timeline validation requiring a zero-duration start marker, positive split durations, and increasing persistence identities.
   * Preserved repeated positive split durations as independent measurements.
   * Continued deriving laps from accumulated persisted split durations while retaining the closing split identity and comment.

5. **Repository cache and database relation tests**

   * Added failed-read and failed-write scenarios for training and history repositories.
   * Verified that failures preserve the last valid immutable cache snapshot.
   * Added coverage for successful training and history comment updates in repository caches.
   * Preserved history-duration merge coverage after successful deletion transactions.
   * Added schema-contract tests for user-to-training and training-to-history delete cascades.

6. **Routing and domain tests**

   * Added coverage confirming centralized route names and paths are unique.
   * Added coverage for typed history route arguments and custom transition timing.
   * Added persisted and derived event-origin assertions.
   * Added timeline-generation coverage for missing start markers, zero-duration splits, invalid persistence order, repeated split durations, and derived lap metadata.

7. **Dependencies**

   * Added `go_router` as a direct application dependency and updated the lockfile with the resolved package version.

8. **Architecture and restructuring documentation**

   * Updated the current architecture and MVVM restructuring plan to describe `MaterialApp.router`, centralized routing, typed arguments, route transitions, and Page-owned navigation.
   * Clarified that ViewModels remain independent of `BuildContext` and navigation APIs.
   * Updated the backlog execution rules and later backlog boundaries to use the centralized `go_router` configuration instead of Navigator 1.0.

9. **Backlog 006 planning and tracking**

   * Added the ordered task plan for migrating trainings and histories to domain-oriented repositories, coordinated operations, ViewModels, and typed UI contracts.
   * Documented the decisions to rely on persistence cascades, persist fundamental timeline events, derive laps in the domain, and keep multi-training selection as transient UI state.
   * Marked the domain-semantics and repository-boundary tasks as delivered with their associated validation evidence.
   * Linked the main backlog document to its task plan and closed its outstanding architectural questions.

10. **`Changelog.md`**

   * Added entries documenting the routing migration, repository-boundary validation, training-event semantics, and backlog 006 planning decisions.

### Conclusion

The application now uses a centralized, typed, and observable declarative routing boundary while preserving navigation ownership in Pages. Training timelines explicitly distinguish persisted events from derived laps and reject invalid persisted sequences.

Repository and schema tests provide evidence that cache failures preserve valid state and that relational deletion behavior remains enforced by SQLite cascades. Documentation now reflects these routing, domain, persistence, and backlog decisions.

## 2026/08/20 - go-router-migration

This change replaces the Navigator 1.0 route table with a centralized
`go_router` configuration modeled after `go-list2/mobile/lib/core/routing`.

1. **Routing foundation**

   * Added centralized route names and paths, a `GoRouter` factory, grouped main
     routes, a shared route observer, and the reference fade/scale transition.
   * Made `/stopwatch` the declarative initial location.
   * Added `go_router` as an application dependency.

2. **Typed navigation**

   * Replaced page-level `Navigator.pushNamed` calls with named `go_router`
     navigation.
   * Replaced dynamic argument maps for personal training and history with
     dedicated typed argument classes.
   * Kept direct `Navigator.pop` only for modal routes such as dialogs and the
     drawer.

3. **Application composition**

   * Migrated `MyMaterialApp` to `MaterialApp.router` with a stable router
     lifecycle.
   * Moved route dependency composition out of the widget's build method.
   * Removed duplicated route-name constants from feature widgets.

4. **Tests and documentation**

   * Added coverage for unique centralized routes, typed history arguments, and
     custom transition timing.
   * Updated active architecture, migration plan, and backlog documents to
     reflect the superseding routing decision.

### Conclusion

Page navigation now has one declarative, observable, and typed routing boundary
while ViewModels remain independent of `BuildContext` and navigation APIs.

## 2026/08/20 - bkl006/task-02

This change completes the repository-boundary task for trainings and histories
by validating typed domain contracts, cache behavior, comment updates, and the
SQLite cascade contract.

1. **Repository cache tests**

   * Added failed-read and failed-write scenarios for training and history
     repositories.
   * Confirmed that the last valid immutable snapshot is preserved on failure.
   * Covered successful training and history comment updates in their caches.
   * Preserved coverage for cache isolation and history-duration merging.

2. **Database relation tests**

   * Added schema-contract coverage for the user-to-training delete cascade.
   * Added schema-contract coverage for the training-to-history delete cascade.
   * Reused the existing database-service coverage that enables SQLite foreign
     keys for every opened connection.

3. **Backlog documentation**

   * Recorded that repository boundaries expose only domain models and keep
     SQLite maps inside data mappers and services.
   * Marked task 2 as delivered with cache and relational-integrity evidence.

### Conclusion

Training and history repositories now have explicit evidence that failures do
not corrupt their caches and that training deletion can rely on SQLite cascade
without coordinating individual history deletions.

## 2026/08/20 - bkl006/task-01

This change completes the first task of backlog 006 by making persisted and
derived training events explicit and validating the fundamental history
timeline before generating splits and laps.

1. **Training domain events and generation**

   * Added event-origin metadata that marks starts and splits as persisted and
     laps as derived.
   * Required a zero-duration start marker before measured splits.
   * Rejected zero-duration splits and histories outside persistence order.
   * Preserved repeated positive split durations as valid independent
     measurements.
   * Kept laps derived from the sum of the persisted splits in each lap cycle.

2. **Domain tests**

   * Covered persisted and derived event classification.
   * Covered missing starts, zero-duration splits, invalid persistence order,
     repeated durations, and derived lap metadata.

3. **Backlog documentation**

   * Marked task 1 as delivered with its domain rules and validation evidence.
   * Clarified that persisted split durations are segment durations and that a
     lap is their derived sum.

### Conclusion

Fundamental history events now have an explicit, validated domain boundary,
and derived laps cannot be confused with additional persisted records.

## 2026/08/20 - bkl006/planejamento

This change prepares backlog 006 for execution by resolving its architectural
questions and splitting the migration of trainings and histories into ordered,
verifiable tasks.

1. **`doc/backlog/006-treinos-e-historicos.md`**

   * Recorded that training deletion relies on the persistence cascade.
   * Established that fundamental events are persisted and remaining history
     representations are derived by the domain.
   * Assigned multiple-training selection to transient UI state.
   * Closed the backlog's open questions and linked its task plan.

2. **`doc/backlog/006-treinos-e-historicos-tasks.md`**

   * Added nine ordered tasks covering domain semantics, repositories,
     coordinated operations, ViewModels, UI migration, dependency injection,
     legacy removal, tests, and delivery validation.
   * Added explicit dependencies, expected results, and a completion rule.

### Conclusion

Backlog 006 is ready for incremental execution with its persistence, domain,
and UI ownership decisions documented.

## 2026/08/19 - bkl005/task-08-ajuste

This change updates the users page so its floating action buttons react to view-model state changes, ensuring the add-user action reflects the current loading status. It also refreshes several application dependencies.

1. **`lib/features/users_page/users_page.dart`**

   * Wrapped the floating action button group in a `ListenableBuilder` connected to the users page view model.
   * Enabled reactive rebuilding of the add-user button when `isLoading` changes.
   * Preserved the existing back-navigation and add-user actions, layout, icons, and hero tags.

2. **`pubspec.yaml`**

   * Updated `image_picker` from `1.0.7` to `1.2.3`.
   * Updated `easy_localization` from `3.0.5` to `3.0.8`.
   * Updated `url_launcher` from `6.3.0` to `6.3.2`.
   * Updated `flutter_native_splash` from `2.4.1` to `2.4.8`.

### Conclusion

The users page now keeps its floating actions synchronized with loading-state notifications, while key Flutter dependencies have been upgraded to newer compatible versions.

## 2026/08/19 - bkl005/task-08

This change completes the users and images backlog, finalizing its MVVM integration, dependency registration, and automated validation. The composition root is reorganized into focused registration modules, the legacy users controller is removed, and user ViewModels are now created through an injected factory.

Backlog documentation is closed with delivery evidence, transferred limitations, validation results, and corrected navigation links.

1. **`doc/backlog/`**

   * Marked backlog 005 as completed in the backlog index and updated backlog 006 to reference the closed users and images documentation.
   * Corrected links between completed backlogs and their successor documents.
   * Moved the backlog 005 specification and task list into `doc/backlog/closed/`.
   * Recorded completion of dependency registration, migration cleanup, automated tests, and delivery validation.
   * Documented the deferred removal of `UserManager`, the temporary legacy `UserModel` conversion, and the reason manual mobile validation was waived.

2. **`lib/core/config/dependencies.dart` and `lib/core/config/dependencies/`**

   * Refactored the composition root into separate service, repository, use-case, ViewModel, and application dependency registration modules.
   * Preserved the idempotent setup flow and centralized the final injector commit and stopwatch configuration.
   * Registered image selection, compression, and storage services as singletons.
   * Registered `UsersUseCase` as a transient dependency and `UsersViewModelFactory` as a singleton.
   * Retained legacy managers and controllers required by training, history, stopwatch, database, and bootstrap flows.

3. **Users page legacy controller**

   * Removed `UsersPageController` and its state hierarchy after migrating user operations and image coordination to the MVVM-based users feature.
   * Eliminated the controller’s direct image compression, filesystem cleanup, and `UserManager` coordination responsibilities.

4. **`lib/ui/pages/users/users_view_model_factory.dart` and `lib/main.dart`**

   * Added `UsersViewModelFactory` to create a fresh `UsersViewModel` and transient `UsersUseCase` for each users route opening.
   * Passed the current active user IDs into each newly created ViewModel.
   * Updated application startup to resolve the registered factory instead of constructing the users ViewModel and use case directly.

5. **`lib/manager/user_manager.dart`**

   * Updated the adapter documentation to clarify that `UserManager` remains only for the legacy training flow and is scheduled for removal in backlog 006.

6. **`test/application/users/users_use_case_test.dart`**

   * Added an integration-style filesystem test verifying that a successful user image update preserves the promoted image and removes the previous file.
   * Extended the repository fake to accept initial users and derive stored photo references from its user cache when explicit references are absent.

7. **`test/core/config/dependencies_test.dart`**

   * Expanded composition-root coverage for image services, `UsersUseCase`, and `UsersViewModelFactory`.
   * Verified singleton lifetimes for image services and the factory, transient lifetimes for the use case and generated ViewModels, and preservation of route-specific active user IDs.

8. **`test/ui/pages/users/users_view_model_test.dart`**

   * Added coverage confirming that a failed reload reports failure without discarding the previously loaded user cache.

### Conclusion

The users and images backlog is formally closed with its MVVM dependency graph integrated into the composition root and its obsolete page controller removed. Dependency lifetimes and per-route ViewModel creation are now explicitly managed and tested.

The expanded tests validate cache preservation and real filesystem image replacement behavior, while remaining legacy training and stopwatch boundaries are documented for subsequent backlogs.

## 2026/08/19 - bkl005/task-03

This change introduces a dedicated user use case that coordinates repository mutations with image selection, compression, promotion, rollback, and cleanup. It protects persisted user data and image references when storage or database operations fail.

The users interface now operates on domain models through a command-based ViewModel. Image previews remain temporary until submission, selection state is centralized, and the existing stopwatch integration and named route are preserved.

1. **`lib/domain/models`**

   * Moved image selection, prepared-image, and stored-image models from the data layer into the shared domain layer.
   * Added `ImagePreparation` results to distinguish canceled selection from successfully prepared images.

2. **`lib/domain/usecases/users/users_use_case.dart`**

   * Added `UsersUseCase` to coordinate the user repository with image selection, compression, and storage services.
   * Added image preparation and explicit temporary-image disposal operations.
   * Promoted prepared images before user insertion or update and prevented repository mutations when promotion fails.
   * Added compensating image removal when insertion or update fails after promotion.
   * Preserved the primary repository error when compensation succeeds and included both primary and compensation failures when rollback fails.
   * Cleaned unused images only after successful updates and deletions, using current persisted photo references.
   * Rejected deletion requests for users without persisted IDs.

3. **`lib/data/services/images`**

   * Updated image service contracts and implementations to consume the relocated domain image models.
   * Added a camera-backed `ImageSelectionServiceImpl` factory using `ImagePicker`.
   * Preserved injectable selection, compression, directory, and storage behaviors for testing and platform composition.

4. **`lib/core/config/dependencies.dart`**

   * Registered camera image selection, platform image compression, and platform user-image storage services.
   * Registered `UsersUseCase` with its repository and service dependencies.

5. **`lib/ui/pages/users/users_view_model.dart`**

   * Added a command-based `UsersViewModel` for loading, adding, editing, deleting, preparing images, and discarding temporary images.
   * Exposed users directly from the use-case-backed repository cache.
   * Consolidated loading and latest-error state across all commands.
   * Initialized active and selected user IDs from the stopwatch state and exposed immutable selection collections.
   * Added persisted-user selection management and prevented selected users from being deleted.
   * Added command listener and disposal handling for the ViewModel lifecycle.

6. **`lib/ui/pages/users/models/user_form_result.dart` and user dialog controller**

   * Added `UserFormResult` to return a domain `User` together with an optional prepared image.
   * Refactored `UserController` to use domain models and removed direct file operations and global image-path access.
   * Kept persisted image references separate from temporary preview images.
   * Returned replaced temporary images so callers can discard obsolete previews safely.

7. **Users page and overlay**

   * Replaced the legacy users page controller and duplicated page selection state with `UsersViewModel`.
   * Connected loading, mutation, image preparation, image disposal, selection, and error rendering to ViewModel commands.
   * Preserved dialogs, list interactions, deletion confirmation, route behavior, and the legacy stopwatch handoff through domain-to-legacy conversion.
   * Added ViewModel disposal ownership to `UsersOverlay`.
   * Disabled user creation while an operation is running and retained cached users when later operations report errors.

8. **User dialog and user list widgets**

   * Migrated the dialog and dismissible user tile from legacy user models to domain `User` models.
   * Moved camera selection and image preparation behind injected callbacks.
   * Added cleanup of replaced or canceled temporary images and prevented barrier or back dismissal from bypassing that cleanup.
   * Converted `DismissibleUserTile` to a stateless widget driven by ViewModel selection state and stable user ID keys.
   * Refactored `UserCard` to receive display fields directly, allowing both domain and legacy consumers to use it.

9. **Application composition and training integration**

   * Replaced the users controller factory with a `UsersViewModel` factory initialized from active stopwatch user IDs.
   * Updated the named users route to create the ViewModel and pass it through the overlay.
   * Adapted the training page to the field-based `UserCard` interface without changing its displayed user information.

10. **User use case tests**

   * Added coverage for image preparation, canceled selection, promotion before insertion, promotion failure isolation, and insertion rollback.
   * Added coverage for compensation failures, preservation of existing images during failed updates, post-update cleanup, and deletion-before-cleanup ordering.
   * Verified that failed deletions do not trigger image cleanup.

11. **Users ViewModel and form-controller tests**

   * Added coverage for command loading state, repository-cache exposure, immutable selection, selection changes, and ignored draft-user selection.
   * Verified add, edit, and delete command behavior, selected-user deletion protection, and latest-error lifecycle.
   * Verified separation of persisted image references from prepared previews and cleanup support when previews are replaced.

12. **Existing image service tests**

   * Updated image contract and service tests to import the relocated domain image models.

13. **`doc/backlog/005-usuarios-e-imagens-tasks.md`**

   * Marked the use-case coordination, ViewModel, and users-page migration tasks as completed.
   * Documented the delivered rollback, cleanup, cache-preservation, selection, temporary-preview, and legacy stopwatch integration behavior.

### Conclusion

The user workflow now has explicit domain coordination for repository and image-storage consistency, including compensating cleanup and structured failure reporting.

Presentation state and user operations are centralized in a testable ViewModel, while the migrated UI preserves its existing navigation, visual behavior, and stopwatch integration.

## 2026/08/19 - bkl005/task-02

This change introduces injectable image selection, compression, and storage boundaries for user images. It separates picker output, prepared temporary images, and persisted references while keeping filesystem and plugin types confined to the data layer.

The implementation adds collision-resistant temporary and permanent storage workflows, explicit image-related error codes, cleanup behavior, and test coverage for the new contracts and services.

1. **`lib/core/result/errors/app_error_code.dart`**

   * Added distinct error codes for image selection, compression, storage reads, storage writes, and deletion.
   * Kept image-processing failures distinguishable from existing database storage failures.

2. **`lib/data/services/images` contracts and models**

   * Added interfaces for selecting, compressing, promoting, removing, and cleaning user images.
   * Introduced separate value types for canceled selections, selected images, prepared temporary images, and stored images.
   * Exposed opaque string references instead of leaking `XFile`, `File`, or `Directory` through service contracts.
   * Added value equality for selected, prepared, and stored image models.

3. **`lib/data/services/images/image_selection_service_impl.dart`**

   * Added an injectable gallery-selection implementation backed by `image_picker`.
   * Mapped valid picker output into the image selection model.
   * Represented picker cancellation as a successful expected result.
   * Validated picker references and mapped selection exceptions to dedicated application errors.

4. **`lib/data/services/images/image_compression_service_impl.dart`**

   * Added an injectable compression implementation backed by `flutter_image_compress`.
   * Created a dedicated temporary image directory on demand.
   * Generated collision-resistant target names using timestamps and numeric suffixes.
   * Applied the configured image quality and minimum height during compression.
   * Removed partial output after compression failures and mapped directory, inspection, and compression failures to appropriate image error codes.

5. **`lib/data/services/images/user_image_storage_service_impl.dart`**

   * Added permanent user-image storage under the application documents directory.
   * Promoted prepared images by copying them to collision-resistant destinations without overwriting existing files.
   * Removed temporary source files after successful promotion without invalidating the stored result when temporary cleanup fails.
   * Added idempotent image removal.
   * Added cleanup of unreferenced image files while preserving files matched by persisted reference names.
   * Mapped missing sources and storage access, write, and deletion failures to dedicated application errors.

6. **`test/data/services/images`**

   * Added contract tests for cancellation semantics, model value equality, and distinct image error codes.
   * Added selection tests covering picker mapping, cancellation, and exception handling.
   * Added compression tests covering temporary output, compression parameters, and partial-file cleanup.
   * Added storage tests covering promotion, temporary-file removal, collision handling, idempotent deletion, orphan cleanup, and missing prepared images.

7. **`lib/data/services/README.md`**

   * Documented the image services area and its responsibility for user-image selection, compression, and storage.
   * Clarified that filesystem and picker-specific types remain hidden from consumers.

8. **`doc/backlog/005-usuarios-e-imagens-tasks.md`**

   * Marked the image contract and data-service tasks as completed.
   * Documented the delivered boundaries, model distinctions, error mapping, temporary preparation, permanent storage, collision handling, idempotent removal, and reference-based cleanup.

### Conclusion

The change establishes a replaceable image-processing infrastructure with clear boundaries between selection, preparation, and persistence. User-image workflows now avoid exposing platform filesystem and picker types outside the data layer.

Dedicated failure mapping, safe promotion and cleanup behavior, and focused automated tests provide a reliable foundation for subsequent user persistence coordination.

## 2026/08/19 - bkl005/task-01

This change starts the users and images backlog by converting its open design questions into explicit architectural decisions and an ordered implementation plan. It defines how user selection, image lifecycle, persistence compensation, MVVM responsibilities, and optional UseCase coordination will be handled.

The backlog documentation was also aligned with the completed persistence milestone, updating dependency links and closure records across subsequent work items.

1. **`doc/backlog/005-usuarios-e-imagens-tasks.md`**

   * Added the complete execution plan for migrating user creation, editing, deletion, and selection to MVVM.
   * Defined injectable boundaries for image selection, compression, storage, promotion, and removal.
   * Specified the persistence and compensation sequence needed to prevent broken image references and preserve existing files when database operations fail.
   * Planned `UsersViewModel` commands, presentation state, selection behavior, dependency injection, legacy adapter removal, UI migration, and integration with the existing stopwatch flow.
   * Added test coverage requirements for repository failures, selection rules, image replacement, compensating cleanup, reference safety, and idempotent removal.
   * Documented validation steps and the conditions required to close the backlog.

2. **`doc/backlog/005-usuarios-e-imagens.md`**

   * Linked the new task plan and updated the persistence and MVVM dependencies to their completed backlog documents.
   * Resolved the previously open questions by documenting selection as page-lifecycle `UsersViewModel` state, deferred replacement of persisted images, and explicit compensation between file storage and the database.
   * Added criteria for introducing a UseCase when coordination spans multiple repositories or would make the ViewModel excessively complex.
   * Documented the resulting ownership boundaries between the UI, ViewModel, UseCase, repositories, and image services.
   * Changed the backlog state from planned to in progress as of 2026-08-19.

3. **Dependent backlog documentation**

   * Updated `doc/backlog/006-treinos-e-historicos.md` and `doc/backlog/007-nucleo-cronometro-bloc.md` to reference the closed persistence backlog and identify that dependency as completed.
   * Removed obsolete trailing whitespace from both documents.

4. **`doc/backlog/README.md`**

   * Updated the backlog index so persistence and repositories now link to the closed backlog location.
   * Marked backlog 003 as completed in the roadmap status table.

5. **`doc/backlog/closed/003-persistencia-e-repositories-tasks.md`**

   * Clarified that manual application-opening and initial-data validation was explicitly deferred by the project owner and treated as non-blocking for closure.
   * Preserved the completed status of the validation task while documenting the reason for its exemption.

6. **`doc/backlog/closed/003-persistencia-e-repositories.md`**

   * Marked the persistence and repositories backlog as completed on 2026-08-13.
   * Recorded completion of all tasks and automated validations, the approved deferral of manual startup validation, and the 2026-08-19 revalidation of affected tests, static analysis, and diff checks.

### Conclusion

The users and images backlog now has an actionable MVVM migration plan with defined image safety guarantees, compensation behavior, ownership boundaries, and test expectations.

The documentation also consistently reflects persistence backlog completion, allowing backlog 005 and its dependent architectural work to proceed from an accurate project state.

## 2026/08/14 - bkl004/task-08

This change completes the settings MVVM backlog by introducing a one-way compatibility bridge between the new settings flow and consumers that still depend on `AppSettings`.

It updates dependency wiring, persistence synchronization, appearance handling, and validation coverage while documenting the remaining legacy access points and closing the associated backlog records.

1. **`lib/common/adapters`**

   * Added `LegacySettingsSink` as a temporary interface for synchronizing successfully loaded or persisted domain settings with legacy consumers.
   * Updated the settings domain adapter documentation to associate its eventual removal with backlogs 005, 007, and 010.

2. **`lib/common/singletons/app_settings.dart`**

   * Refactored `AppSettings` into an implementation of `LegacySettingsSink`.
   * Removed its global contrast notifier and direct generic update methods, leaving appearance ownership with `AppAppearanceState`.
   * Changed initialization to receive the appearance state and synchronize loaded domain settings through the compatibility bridge.
   * Converted the legacy brightness toggle into an asynchronous persistence flow that updates legacy and global appearance state only after a successful repository write.
   * Preserved legacy settings values and brightness notifications without triggering a second repository write.

3. **Settings dependency and initialization flow**

   * Registered `AppSettings` as the `LegacySettingsSink` implementation in `lib/core/config/dependencies.dart`.
   * Injected the bridge into `SettingsViewModel`.
   * Updated `DatabaseProvider` to initialize `AppSettings` with both the settings repository and `AppAppearanceState`.
   * Standardized dependency imports to package-root paths.

4. **`lib/ui/pages/settings/settings_view_model.dart`**

   * Added the legacy settings sink as an explicit dependency.
   * Synchronized legacy consumers after successful settings loads.
   * Synchronized each successfully persisted update with the legacy adapter.
   * Kept failed writes from changing the legacy settings cache.

5. **Remaining legacy settings consumers**

   * Documented the planned migration backlog beside remaining `AppSettings` usage in the stopwatch BLoC, stopwatch page, precise stopwatch components, training speed-unit UI, user image controller, and shared icon button.
   * Associated stopwatch and training settings access with backlog 007, image-path access with backlog 005, and shared UI appearance access with backlog 010.

6. **Settings conversion and synchronization tests**

   * Added `settings_form_data_test.dart` to verify complete round-trip conversion between domain settings and UI form data, including distances, units, brightness, contrast, locale, and refresh interval.
   * Added coverage ensuring invalid form values are rejected before persistence.
   * Extended `settings_view_model_test.dart` with a fake legacy sink and assertions for load synchronization, successful persistence, contrast and locale changes, ordered rapid updates, and failed-write isolation.
   * Updated dependency configuration tests to verify that `LegacySettingsSink` resolves to the registered `AppSettings` instance.

7. **`doc/backlog/closed/004-configuracoes-mvvm*.md`**

   * Moved the settings MVVM backlog and task checklist into the closed backlog folder.
   * Marked the compatibility, testing, architectural, formatting, analysis, and validation tasks as completed.
   * Recorded successful focused and full test runs, static analysis, formatting, and diff validation.
   * Documented the decision to close the backlog while deferring the listed manual validation execution to the responsible maintainer.
   * Updated the backlog status to completed on 2026-08-13.

8. **`doc/backlog/README.md`**

   * Updated backlog 004 to link to its closed document.
   * Changed its status from dependency-based tracking to completed.

### Conclusion

The settings feature now completes its MVVM migration while maintaining one-way compatibility for consumers scheduled for later backlogs. Persisted settings consistently update both global appearance state and legacy consumers without duplicate writes or synchronization cycles.

The implementation is covered across conversion, persistence, dependency registration, synchronization, and failure behavior, and backlog 004 is formally closed with its validation results recorded.

## 2026/08/13 - bkl004/task-07

This change advances the settings feature to an MVVM architecture with explicit dependency injection, observable global appearance state, immediate persistence, and controlled failure handling.

The settings UI now operates through a dedicated ViewModel, while application-level theme, contrast, and locale updates are coordinated through a single presentation-state object. The change also adds implementation tracking, behavioral tests, and removes the Linux desktop runner.

1. **`doc/backlog/004-configuracoes-mvvm-tasks.md`**

   * Added a detailed task plan for migrating settings to MVVM.
   * Recorded architectural decisions, dependencies, expected outcomes, completed work, and validation results.
   * Documented the remaining legacy-adapter, testing, and final-delivery tasks.

2. **`doc/backlog/004-configuracoes-mvvm.md`**

   * Updated the scope to reuse the settings repository delivered by backlog 003.
   * Renamed the planned global presentation component from `AppSettingsViewModel` to `AppAppearanceState`.
   * Changed the backlog status from planned to in progress and linked the task checklist.

3. **`lib/ui/app/app_appearance_state.dart`**

   * Added a global `ChangeNotifier` dedicated to brightness, contrast, and locale.
   * Added explicit synchronization from domain `Settings` and consolidated presentation updates into a single notification.
   * Introduced `AppContrast` and conversions between domain preferences and Flutter presentation types.

4. **`lib/ui/pages/settings/`**

   * Added `SettingsFormData` as an immutable UI model with conversions to and from domain settings.
   * Added `SettingsViewModel` with constructor-injected repository and appearance-state dependencies.
   * Added commands for loading and saving settings, including observable loading, success, and failure states.
   * Implemented immediate optimistic updates for distances, units, appearance, locale, and refresh interval.
   * Serialized rapid edits by retaining the latest pending valid state during active persistence.
   * Added rollback to the repository’s last persisted state when validation or storage updates fail.
   * Added explicit disposal of command resources.

5. **`lib/core/config/dependencies.dart` and `lib/main.dart`**

   * Registered `AppAppearanceState` as a singleton initialized from default domain settings.
   * Registered `SettingsViewModel` as a transient dependency with explicit constructor injection.
   * Passed the shared appearance state and the settings ViewModel factory into the application root.
   * Updated application imports to use the relocated `MyMaterialApp`.

6. **`lib/data/services/database/database_provider.dart`**

   * Injected `AppAppearanceState` into the database bootstrap provider.
   * Synchronized global appearance values from the settings repository cache after legacy settings initialization.
   * Reused the existing loaded settings instead of initiating another repository read.

7. **`lib/ui/app/my_material_app.dart` and `lib/my_material_app.dart`**

   * Relocated `MyMaterialApp` into the UI application module.
   * Refactored the application root into a stateful widget that observes the injected `AppAppearanceState`.
   * Removed direct dependence on the legacy `AppSettings` singleton.
   * Derived the active theme from observable brightness and contrast values.
   * Synchronized the observed locale with `EasyLocalization` after frame rendering.
   * Preserved the existing initial route, named routes, Navigator 1.0 behavior, themes, and supported localization configuration.
   * Added route-level creation of transient settings ViewModels.

8. **`lib/features/settings/settings_overlay.dart`**

   * Changed the overlay to receive a `SettingsViewModel` through its constructor.
   * Converted the overlay to a stateful composition boundary.
   * Passed the ViewModel into `SettingsPage` and disposed it when the overlay leaves the widget tree.

9. **`lib/features/settings/settings_page.dart`**

   * Removed direct access to `AppSettings` and the deferred save-on-navigation behavior.
   * Loaded settings through the ViewModel during page initialization.
   * Added observation of the ViewModel and its load and save commands.
   * Added progress and error presentation for loading and immediate persistence operations.
   * Bound distance, unit, brightness, contrast, locale, and refresh controls to immutable form state.
   * Routed every valid settings change through the ViewModel while retaining visual controllers and Flutter context in the UI layer.

10. **`lib/features/settings/widgets/length_line_edit.dart`**

   * Added callbacks for distance and unit changes.
   * Replaced the local unit controller with the unit supplied by the parent state.
   * Corrected the length controller naming and synchronized it when external values change.
   * Added a 400-millisecond debounce for valid positive distance edits and immediate handling on submission.
   * Prevented invalid, unchanged, or incomplete values from being emitted.
   * Added cleanup for the debounce timer and text controller.

11. **Settings MVVM and dependency tests**

   * Added unit tests for `AppAppearanceState` initialization, synchronization, notification behavior, and no-op updates.
   * Added ViewModel tests for successful and failed loading, immediate persistence, domain conversions, queued edits, rollback, and invalid input.
   * Extended dependency configuration tests to verify singleton identity for the appearance state and transient lifecycle for settings ViewModels.
   * Added widget tests covering debounced positive distance changes and common unit selection.

12. **`linux/`**

   * Removed the Linux Flutter runner, CMake configuration, generated plugin registration files, application sources, and Linux-specific ignore rule.
   * Removed the project’s checked-in Linux desktop build target and its plugin wiring.

### Conclusion

The settings flow now has an MVVM foundation with explicit composition, immutable presentation data, immediate serialized persistence, and a single observable source for application appearance and locale.

The application root and settings page no longer depend directly on the legacy settings singleton for presentation behavior, and the altered flows are covered by focused unit, widget, and dependency-lifecycle tests. The Linux desktop runner has also been removed from the project.

## 2026/08/13 - bkl004/totorial-off

This change removes the tutorial and onboarding system from the application, simplifying the stopwatch, user, training, and settings flows to render their pages directly without guided overlays.

Tutorial state was also removed from the settings domain, legacy models, persistence mappings, and tests. The related dependency, localization content, focus-node infrastructure, and UI entry points were cleaned up while retaining the legacy database column for compatibility.

1. **Application translation resources**

   * Removed stopwatch, user management, settings, and training tutorial titles and messages from the English, Spanish, and Brazilian Portuguese translation files.
   * Preserved the existing localized history dialog title in each language.

2. **Settings domain, legacy model, and adapters**

   * Removed `showTutorial` from the domain `Settings` entity, including creation defaults, equality, and hash calculation.
   * Removed tutorial state from `SettingsModel`, its copy behavior, serialization, and database-map parsing.
   * Updated domain and legacy adapters to stop transferring tutorial state between settings representations.

3. **Settings persistence services**

   * Removed tutorial-state mapping from `SettingsMapper` when reading and writing persisted settings.
   * Updated `SettingsService` to construct settings without the removed tutorial property.
   * Left the legacy database column outside the active domain and UI model for compatibility.

4. **`AppSettings` legacy adapter**

   * Removed the global tutorial flags, selected tutorial user identifier, tutorial-state checks, and tutorial disabling behavior.
   * Removed the shared tutorial focus-node collection and its disposal lifecycle.
   * Retained the singleton as a temporary adapter for remaining legacy settings consumers.

5. **Overlay route widgets**

   * Refactored settings, stopwatch, trainings, and users overlay widgets from stateful onboarding containers into stateless route wrappers.
   * Removed all onboarding step definitions, localized tutorial content, custom tutorial panels, callback flows, and tutorial image presentations.
   * Preserved existing page controllers and sharing dependencies while passing them directly to their respective pages.

6. **Stopwatch feature**

   * Removed automatic tutorial startup and continuation after adding users.
   * Removed tutorial focus assignments from the app bar, drawer, stopwatch list, floating action button, dismissible stopwatch entries, and stopwatch controls.
   * Removed the tutorial drawer entry and simplified `StopwatchDrawer` by eliminating its focus-node dependency.
   * Decoupled the stopwatch button bar and dismissible widget from `AppSettings` tutorial state.

7. **Users feature**

   * Removed tutorial initialization, continuation, interruption, and popup-menu entry points from the users page.
   * Simplified user creation by removing tutorial-specific result handling and delays.
   * Removed tutorial focus wrappers from user tiles and navigation buttons.
   * Removed tutorial user tracking from `UsersPageController`.

8. **Trainings feature**

   * Removed tutorial initialization and the tutorial popup-menu action from the trainings page.
   * Removed tutorial focus assignments from user selection, training lists, bulk controls, deletion, sharing, and selection actions.
   * Decoupled the user-selection popup from `AppSettings`.

9. **Settings feature**

   * Removed onboarding initialization and the tutorial menu action from the settings page.
   * Removed tutorial focus assignments from default values, appearance, language, and refresh interval controls.
   * Kept the existing settings interface and editing behavior intact without tutorial orchestration.

10. **Dependencies**

   * Removed the direct `onboarding_overlay` dependency from `pubspec.yaml`.
   * Removed `onboarding_overlay` and its transitive `auto_size_text` package entries from the lockfile.

11. **Settings tests**

   * Updated domain model, service, and adapter tests to stop constructing or asserting tutorial state.
   * Preserved coverage for the remaining settings defaults, conversions, and persistence behavior.

12. **`doc/backlog/004-configuracoes-mvvm.md`**

   * Updated the MVVM migration scope to explicitly maintain the tutorial system’s removal.
   * Resolved the open architectural questions with decisions covering global observable settings, repository responsibilities, immediate persistence, view-model synchronization, and the temporary legacy adapter.
   * Documented that tutorial state no longer belongs to persisted settings or the UI while the legacy database column remains for compatibility.

### Conclusion

The application no longer exposes or executes guided tutorials across its primary workflows. Pages now operate without onboarding overlays, tutorial focus management, or tutorial-specific settings state.

The removal simplifies UI composition and settings architecture, eliminates an unused dependency, and prepares the settings feature for its planned MVVM migration while preserving database compatibility.

## 2026/08/13 - bkl003/task12

This change completes the automated validation and documentation updates for the persistence and repositories backlog while recording the deferred manual application startup check. It also modernizes the iOS integration by migrating Flutter plugin dependencies from CocoaPods to Swift Package Manager and updating the application lifecycle configuration.

The change set additionally updates the iOS deployment target, refreshes image compression support, and aligns repository metadata and temporary adapter documentation with the upcoming migration work.

1. **`.gitignore`**

   * Added `.build/` and `.swiftpm/` to exclude generated build artifacts and local Swift Package Manager state from version control.

2. **`doc/backlog/closed/003-persistencia-e-repositories-tasks.md`**

   * Moved the task checklist from the active backlog folder into `doc/backlog/closed/`.
   * Marked the formatting, testing, analysis, diff verification, persistence flow, backup fallback, deferred adapter registration, tracking update, and backlog archival tasks as completed.
   * Recorded that manual application startup and initial data reading were deferred by the project owner on 2026-08-13.

3. **`doc/backlog/closed/003-persistencia-e-repositories.md`**

   * Moved the persistence and repositories backlog document into the closed backlog folder.
   * Updated its tracking status to report completion of task 12’s automated validations.
   * Documented that the backlog remains pending the deferred manual application startup and initial-data validation.

4. **`ios/Flutter`**

   * Removed CocoaPods configuration includes from the Debug and Release build settings, leaving Flutter’s generated Xcode configuration as the build source.
   * Removed the fixed minimum OS version from `AppFrameworkInfo.plist` so the deployment target is managed through the Xcode project configuration.

5. **`ios/Podfile`**

   * Removed the CocoaPods setup, Flutter pod installation hooks, Runner test inheritance, and post-install build configuration now superseded by Swift Package Manager integration.

6. **`ios/Runner.xcodeproj`**

   * Registered Flutter’s generated local Swift package and linked its package product to the Runner target.
   * Added framework build phases for the application and test targets.
   * Raised the iOS deployment target from 12.0 to 13.0 across project build configurations.
   * Added locked Swift package resolutions for SDWebImage, SDWebImageWebPCoder, and libwebp-Xcode.
   * Added a build pre-action to prepare the Flutter framework before Xcode builds.
   * Configured Flutter’s generated LLDB initialization file for testing and running, and enabled GPU validation for the launch action.

7. **`ios/Runner.xcworkspace`**

   * Added the Swift Package Manager resolution file with pinned versions and revisions for the image-related native dependencies.

8. **`ios/Runner/AppDelegate.swift`**

   * Migrated the application entry point from `@UIApplicationMain` to `@main`.
   * Adopted `FlutterImplicitEngineDelegate`.
   * Moved generated plugin registration to the implicit Flutter engine initialization callback and its plugin registry.

9. **`ios/Runner/Info.plist`**

   * Added the UIKit scene manifest using `FlutterSceneDelegate` and the existing Main storyboard.
   * Declared that the application does not support multiple scenes.
   * Preserved the application metadata, localization, launch storyboard, orientation, status bar, frame-duration, and indirect-input settings while reorganizing the property list structure.

10. **`lib/common/adapters`**

   * Updated the history and training domain adapter comments to identify backlog 006 as the point where these temporary legacy bridges will be removed.

11. **`pubspec.yaml`**

   * Upgraded `flutter_image_compress` from `^2.3.0` to `^2.5.1`, aligning the Flutter dependency with the updated native package integration.

### Conclusion

The change set records the completed persistence validation work and archives its backlog documentation while explicitly retaining the deferred manual startup check.

The iOS project now uses Flutter’s Swift Package Manager integration, adopts the implicit-engine and scene-based lifecycle configuration, targets iOS 13, and locks the required native image dependencies.

## 2026/08/13 - bkl003/task11

This change completes the persistence and repository migration by consolidating SQLite infrastructure under the data layer, composing the full dependency graph through `AutoInjector`, and removing the superseded stores, repositories, managers, and database singleton.

Legacy screens remain operational through injected adapters and controllers, while settings, reporting, sharing, and stopwatch workflows now consume the new repository chain. The architecture and backlog documentation were updated to reflect the delivered structure and migration status.

1. **`lib/core/config/dependencies.dart` and `lib/main.dart`**

   * Expanded the composition root to register database services, domain-oriented repositories, temporary managers, sharing services, page controllers, and stopwatch controllers.
   * Applied singleton lifecycles to the database service, cached repositories, sharing service, and stopwatch page controller while keeping transient services and screen adapters resolvable per use.
   * Configured stopwatch controller creation through an injected factory.
   * Updated application startup to resolve entry-point dependencies and pass controller factories and shared services into `MyMaterialApp`.

2. **`lib/data/services/database` and `lib/core/bootstrap/bootstrap.dart`**

   * Moved `DatabaseProvider`, schema constants, and SQL scripts from the legacy `store` hierarchy into the database service module.
   * Added `database_service_factory.dart` to encapsulate platform-specific database directory and `sqflite` operations outside the composition root.
   * Updated schema, database service, mappers, CRUD services, and bootstrap imports to use the consolidated data-layer infrastructure.
   * Extended `DatabaseProvider` to inject `SettingsRepository` and initialize application settings only after the database opens successfully.

3. **`lib/data/repositories` integration**

   * Registered settings, users, trainings, and histories repository implementations against their corresponding data services.
   * Established repositories as the cache-owning persistence boundary consumed by managers, application settings, reporting, and sharing workflows.
   * Preserved controlled `Result` failure handling throughout repository-backed operations.

4. **`lib/manager`**

   * Refactored `UserManager`, `TrainingManager`, and `HistoryManager` into temporary constructor-injected UI adapters over the new repositories.
   * Removed manager-owned entity lists and exposed legacy models by adapting repository caches.
   * Migrated CRUD, loading, photo-reference lookup, and history merge behavior to repository APIs with explicit failure propagation.
   * Marked the adapters for removal by their owning future backlogs.
   * Removed the static `SettingsManager`; settings now access the injected settings repository directly.

5. **`lib/common/singletons/app_settings.dart`**

   * Changed settings initialization to receive a `SettingsRepository`, load domain settings, and convert them through the legacy adapter.
   * Replaced static manager updates with domain conversion and repository-backed persistence.
   * Added propagation of conversion, read, and write failures.

6. **`lib/common/functions/build_pdf.dart` and `lib/common/functions/share_functions.dart`**

   * Injected `HistoryRepository` into report generation instead of constructing the removed legacy repository internally.
   * Loaded report histories through the repository API and converted domain entries to legacy report models.
   * Refactored `AppShare` from a static utility into an injectable service whose email and WhatsApp workflows share the repository-backed PDF path.

7. **`lib/features/users_page`, `lib/features/trainings_page`, and `lib/features/history_page`**

   * Added constructor injection for page controllers and propagated dependencies through overlays and route builders.
   * Updated users and trainings controllers to receive managers and factories instead of accessing static instances or constructing dependencies internally.
   * Passed the shared stopwatch controller into the users flow so selections update the composed stopwatch state.
   * Injected `AppShare` into the trainings flow for repository-backed email and WhatsApp reporting.
   * Injected `HistoryPageController` and its history manager into the history screen.

8. **`lib/features/stopwatch_page` and `lib/features/widgets/precise_stopwatch`**

   * Removed the static `StopwatchPageController` singleton API and supplied the composed controller through the overlay and page constructors.
   * Added an injected precise-stopwatch controller factory for dynamically created stopwatches.
   * Refactored `PreciseStopwatchController` to receive training, history, and stopwatch dependencies through its constructor.
   * Ensured training initialization completes asynchronously before creating stopwatch training state.

9. **`lib/my_material_app.dart`**

   * Added application-level dependencies for the stopwatch controller, page-controller factories, and sharing service.
   * Updated navigation routes to create screens with dependencies supplied from the composition root.
   * Preserved route-based navigation while eliminating injector access and internal controller construction from feature widgets.

10. **Legacy persistence modules**

   * Removed the old history, settings, training, and user repository contracts and implementations under `lib/repositories`.
   * Removed `DatabaseManager`, legacy database backup and table-creation helpers, and all entity stores under `lib/store`.
   * Relocated the remaining schema constants and database provider into the new data service structure, leaving a single persistence implementation.

11. **`test/core/config/dependencies_test.dart` and legacy store tests**

   * Expanded dependency resolution coverage to verify the bootstrap graph and the configured lifecycles of the database service, transient settings service, and cached repositories.
   * Retained the idempotency check for repeated dependency setup.
   * Removed the obsolete legacy `DatabaseCreateTable` test alongside the deleted store implementation.

12. **`doc/backlog/003-persistencia-e-repositories*.md`**

   * Marked dependency composition, temporary adapter migration, legacy persistence cleanup, and architecture verification tasks as completed.
   * Documented the delivered data-service, repository, manager, composition-root, and navigation structure.
   * Recorded the remaining lifecycle of `AppSettings` and temporary managers under subsequent backlogs.
   * Updated backlog status to show tasks 1 through 11 completed with final validation assigned to task 12.

13. **Dart source formatting**

   * Normalized whitespace in GPL license headers across bloc, common, feature, widget, model, theme, and controller files without changing their runtime behavior.

### Conclusion

The application now uses a single repository-backed persistence architecture composed centrally through dependency injection. Legacy screens continue to function through temporary adapters while persistence state and SQLite access remain confined to the new data layer.

The obsolete store and repository stack has been removed, and bootstrap, settings, reporting, navigation, controllers, tests, and documentation now reflect the delivered architecture.

## 2026/08/13 - bkl003/task08

This change introduces typed persistence services and repository-level caching for users, trainings, histories, and settings. SQLite records are now converted through dedicated mappers, while repositories expose domain-oriented operations and update immutable in-memory state only after successful persistence.

History deletion is made transactional, preserving duration continuity and rolling back failed merges. The dependency configuration, error model, tests, and backlog documentation were updated to support the new data architecture.

1. **`lib/data/services/users`**

   * Added `UserMapper` to convert between SQLite records and `User` models, returning `invalidData` failures for malformed persisted values.
   * Added `UserService` with database-backed insert, individual lookup, ordered listing, update, deletion, and photo-reference queries.
   * Added generated-ID handling, immutable list results, missing-ID validation, structured storage errors, and `storageNotFound` responses when records are absent.

2. **`lib/data/services/trainings`**

   * Added `TrainingMapper` to translate persisted dates, distances, limits, comments, and unit symbols into typed `Training` models.
   * Reused domain parsers for distance and speed units so unknown persisted symbols produce `invalidData` failures.
   * Kept color outside the persisted training representation and preserved metric and imperial distance values without conversion or rounding.
   * Added `TrainingService` with insert, lookup, per-user listing, update, and deletion operations, including immutable results and structured validation and storage failures.

3. **`lib/data/services/histories`**

   * Added `HistoryMapper` for converting history records and millisecond durations to and from `HistoryEntry` models.
   * Added `HistoryService` with insert, lookup, ordered per-training listing, update, and transactional deletion.
   * Implemented deletion that transfers the removed duration to the following entry when present, permits deletion of the final non-initial entry, and rejects deletion of the initial entry.
   * Ensured deletion and duration merging roll back together when either database operation fails.
   * Added history-specific read, write, validation, and not-found errors without references to the legacy training store.

4. **`lib/data/repositories`**

   * Added domain-oriented contracts and implementations for settings, users, trainings, and histories.
   * Added immutable user caches, per-user training caches, and per-training history caches populated by successful reads.
   * Updated repository caches only after successful writes, preserving their previous state when persistence fails.
   * Added settings state management that loads persisted settings or creates and inserts defaults when none exist.
   * Added history cache synchronization that mirrors successful duration merging after transactional deletion.
   * Kept user photo-reference access within the user data boundary.

5. **`lib/core/config/dependencies.dart`**

   * Registered the new history, user, and training mappers as dependency instances.
   * Registered the corresponding persistence services for constructor injection alongside the existing settings service.

6. **`lib/core/result/errors/app_error_code.dart` and `lib/data/services/settings/settings_service.dart`**

   * Added the `storageNotFound` error code for individual persistence operations that cannot locate a requested record.
   * Made `SettingsService` extensible so repository tests can provide controlled service fakes.

7. **`test/data/services`**

   * Added user service coverage for CRUD behavior, generated IDs, immutable listings, photo-reference filtering, invalid records, missing IDs, and absent records.
   * Added training service coverage for CRUD behavior, typed unit mapping, immutable listings, missing records and IDs, invalid unit symbols, excluded color data, and preservation of imperial values.
   * Added history service coverage for CRUD behavior, duration merging, final-entry deletion, initial-entry protection, missing entries, and transactional rollback.

8. **`test/data/repositories`**

   * Added shared database test support for repository service fakes.
   * Added cache synchronization tests for default settings, failed writes, immutable user collections, per-user training isolation, and history duration merging.

9. **`doc/backlog/003-persistencia-e-repositories-tasks.md`**

   * Marked the user, training, and history service migrations as completed while clarifying that legacy stores remain until their consumers are adapted.
   * Marked repository contracts, service injection, immutable caching, failure preservation, and synchronization tests as completed.
   * Updated task wording to reflect the implemented domain parsers and history-specific error handling.

### Conclusion

The data layer now provides injectable, typed services over SQLite and domain-focused repositories with immutable, persistence-synchronized caches. User, training, history, and settings workflows no longer need to expose raw database maps through these new APIs.

Transactional history merging and consistent validation, not-found, read, and write failures improve persistence integrity while the expanded test suite verifies the new behavior.

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
