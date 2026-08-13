# Changelog

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

## [Unreleased]
