import '/domain/common/settings/models/settings.dart';

/// Temporary one-way bridge for settings consumers not migrated to MVVM yet.
abstract interface class LegacySettingsSink {
  void synchronize(Settings settings);
}
