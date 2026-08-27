import 'app_error_code.dart';

export 'app_error_code.dart';

class AppError implements Exception {
  final AppErrorCode code;
  final String message;
  final Object? details;

  const AppError({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'AppError(${code.name}, $message)';
}
