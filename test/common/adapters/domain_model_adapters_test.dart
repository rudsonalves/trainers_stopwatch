import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/common/adapters/history_domain_adapter.dart';
import 'package:trainers_stopwatch/common/adapters/settings_domain_adapter.dart';
import 'package:trainers_stopwatch/common/adapters/training_domain_adapter.dart';
import 'package:trainers_stopwatch/common/adapters/user_domain_adapter.dart';
import 'package:trainers_stopwatch/common/models/history_model.dart';
import 'package:trainers_stopwatch/common/models/settings_model.dart';
import 'package:trainers_stopwatch/common/models/training_model.dart';
import 'package:trainers_stopwatch/common/models/user_model.dart';

void main() {
  test('maps a user in both directions', () {
    final legacy = UserModel(
      id: 1,
      name: 'Ana',
      email: 'ana@example.com',
      phone: '123',
      photo: 'ana.png',
    );

    final restored = legacy.toDomain().toLegacy();

    expect(restored.toMap(), legacy.toMap());
  });

  test('maps a training in both directions and keeps color at the UI edge', () {
    final legacy = TrainingModel(
      id: 2,
      userId: 1,
      date: DateTime(2026),
      comments: 'training',
      splitLength: 200,
      lapLength: 1000,
      maxlaps: 5,
      distanceUnit: 'm',
      speedUnit: 'km/h',
      color: Colors.red,
    );

    final domain = legacy.toDomain();
    final restored = domain.value!.toLegacy(color: Colors.green);

    expect(domain.isSuccess, isTrue);
    expect(restored.toMap(), legacy.toMap());
    expect(restored.color, Colors.green);
  });

  test('rejects an unknown persisted training unit', () {
    final legacy = TrainingModel(
      userId: 1,
      date: DateTime(2026),
      distanceUnit: 'meters',
    );

    expect(legacy.toDomain().isFailure, isTrue);
  });

  test('maps history in both directions including zero duration', () {
    final legacy = HistoryModel(
      id: 3,
      trainingId: 2,
      duration: Duration.zero,
      comments: 'started',
    );

    final restored = legacy.toDomain().value!.toLegacy();

    expect(restored.toMap(), legacy.toMap());
  });

  test('maps settings without moving schema metadata into the domain', () {
    final legacy = SettingsModel(
      id: 1,
      splitLength: 100,
      lapLength: 400,
      lengthUnit: 'yd',
      brightness: Brightness.light,
      contrast: Contrast.high,
      language: const Locale('pt', 'BR'),
      mSecondRefresh: 133,
    );

    final domain = legacy.toDomain();
    final restored = domain.value!.toLegacy();

    expect(domain.isSuccess, isTrue);
    expect(restored.toMap(), legacy.toMap());
  });
}
