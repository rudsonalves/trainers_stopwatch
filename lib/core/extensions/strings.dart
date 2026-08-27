extension StringExtension on String {
  /// Removes all non-numeric characters from the string.
  String get onlyNumbers => replaceAll(RegExp(r'[^\d]'), '');

  String? trimToNull() {
    final trimmed = trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
