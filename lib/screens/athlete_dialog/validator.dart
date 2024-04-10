class Validador {
  static String? name(String? value) {
    if (value == null || value.length < 3) {
      return 'The name must have at last 3 characters';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'The e-mail is mandatory';
    }

    final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegex.hasMatch(value)) {
      return 'This email is invalid';
    }

    return null;
  }
}
