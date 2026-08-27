import 'package:flutter/foundation.dart';

import 'result.dart';

export 'result.dart';

typedef CommandAction0<Output extends Object> = AsyncResult<Output> Function();
typedef CommandAction1<Output extends Object, Input> = AsyncResult<Output>
    Function(Input);

enum CommandState { idle, running, success, failure }

abstract class Command<Output extends Object> extends ChangeNotifier {
  CommandState _state = CommandState.idle;
  Result<Output>? _result;

  CommandState get state => _state;
  bool get isIdle => _state == CommandState.idle;
  bool get isRunning => _state == CommandState.running;
  bool get isSuccess => _state == CommandState.success;
  bool get isFailure => _state == CommandState.failure;
  Result<Output>? get result => _result;
  Output? get value => _result?.value;
  AppError? get error => _result?.error;

  Future<void> executeAction(AsyncResult<Output> Function() action) async {
    if (isRunning) return;

    _state = CommandState.running;
    _result = null;
    notifyListeners();

    try {
      final result = await action();
      _result = result;
      _state = result.isSuccess ? CommandState.success : CommandState.failure;
    } on AppError catch (error) {
      _result = Failure(error);
      _state = CommandState.failure;
    } catch (error, stackTrace) {
      _result = Failure(
        AppError(
          code: AppErrorCode.unexpected,
          message: 'An unexpected error occurred.',
          details: (error: error, stackTrace: stackTrace),
        ),
      );
      _state = CommandState.failure;
    } finally {
      notifyListeners();
    }
  }
}

final class Command0<Output extends Object> extends Command<Output> {
  final CommandAction0<Output> _action;

  Command0(this._action);

  Future<void> execute() => executeAction(_action);
}

final class Command1<Output extends Object, Input> extends Command<Output> {
  final CommandAction1<Output, Input> _action;

  Command1(this._action);

  Future<void> execute(Input input) => executeAction(() => _action(input));
}
