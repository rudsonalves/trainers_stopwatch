import 'errors/app_error.dart';

export 'errors/app_error.dart';
export 'unit.dart';

typedef AsyncResult<T extends Object> = Future<Result<T>>;

sealed class Result<T extends Object> {
  const Result();

  T? get value => null;
  AppError? get error => null;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppError error) onFailure,
  }) {
    return switch (this) {
      Success(:final value) => onSuccess(value),
      Failure(:final error) => onFailure(error),
    };
  }
}

final class Success<T extends Object> extends Result<T> {
  final T _value;

  const Success(this._value);

  @override
  T get value => _value;
}

final class Failure<T extends Object> extends Result<T> {
  final AppError _error;

  const Failure(this._error);

  @override
  AppError get error => _error;
}
