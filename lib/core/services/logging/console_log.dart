import 'package:flutter/foundation.dart';

enum LogLevel { error, warning, info }

final class ConsoleLog {
  final String context;

  const ConsoleLog(this.context);

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (!kDebugMode) return;
    debugPrint('[ERROR][$context] $message');
    if (error != null) debugPrint(error.toString());
    if (stackTrace != null) debugPrint(stackTrace.toString());
  }

  void warning(String message) {
    if (kDebugMode) debugPrint('[WARNING][$context] $message');
  }

  void info(String message) {
    if (kDebugMode) debugPrint('[INFO][$context] $message');
  }
}
