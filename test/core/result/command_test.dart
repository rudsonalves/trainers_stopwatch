import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:trainers_stopwatch/core/result/command.dart';

void main() {
  group('Command0', () {
    test('moves from idle to running and success', () async {
      final completer = Completer<Result<int>>();
      final command = Command0<int>(() => completer.future);
      final states = <CommandState>[];
      command.addListener(() => states.add(command.state));

      final execution = command.execute();
      expect(command.isRunning, isTrue);

      completer.complete(const Success(7));
      await execution;

      expect(command.isSuccess, isTrue);
      expect(command.value, 7);
      expect(states, [CommandState.running, CommandState.success]);
    });

    test('exposes an expected AppError as failure', () async {
      const error = AppError(
        code: AppErrorCode.invalidData,
        message: 'invalid',
      );
      final command = Command0<Unit>(() async => throw error);

      await command.execute();

      expect(command.isFailure, isTrue);
      expect(command.error, same(error));
    });

    test('converts an unexpected exception to unexpected AppError', () async {
      final command = Command0<Unit>(() async => throw StateError('broken'));

      await command.execute();

      expect(command.isFailure, isTrue);
      expect(command.error?.code, AppErrorCode.unexpected);
      expect(command.error?.details, isNotNull);
    });

    test('ignores a second execution while running', () async {
      var calls = 0;
      final completer = Completer<Result<Unit>>();
      final command = Command0<Unit>(() {
        calls++;
        return completer.future;
      });

      final first = command.execute();
      await command.execute();
      expect(calls, 1);

      completer.complete(const Success(unit));
      await first;
    });
  });

  test('Command1 forwards its input to the action', () async {
    String? received;
    final command = Command1<Unit, String>((input) async {
      received = input;
      return const Success(unit);
    });

    await command.execute('athlete');

    expect(received, 'athlete');
    expect(command.isSuccess, isTrue);
  });
}
