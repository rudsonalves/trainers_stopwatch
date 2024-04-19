import 'package:easy_localization/easy_localization.dart';

class Validador {
  static String? name(String? value) {
    if (value == null || value.length < 3) {
      return 'ValidateName'.tr();
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'ValidateEmail'.tr();
    }

    final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegex.hasMatch(value)) {
      return 'ValidateEmailInvalid'.tr();
    }

    return null;
  }
}
